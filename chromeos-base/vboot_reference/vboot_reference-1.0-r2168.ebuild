# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="edcc9cd30731fafc410675ac90e3b90f822e1d9f"
CROS_WORKON_TREE="805f67cbce91b84ce07501d316389282b07416cc"
CROS_WORKON_PROJECT="chromiumos/platform/vboot_reference"
CROS_WORKON_LOCALNAME="platform/vboot_reference"

inherit cros-debug cros-fuzzer cros-sanitizers cros-workon

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host dev_debug_force fuzzer pd_sync test tpmtests tpm tpm_dynamic tpm2 tpm2_simulator vtpm_proxy"

REQUIRED_USE="
	tpm_dynamic? ( tpm tpm2 )
	!tpm_dynamic? ( ?? ( tpm tpm2 ) )
"

COMMON_DEPEND="dev-libs/libzip:=
	dev-libs/openssl:=
	sys-apps/util-linux:="
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

get_build_dir() {
	echo "${S}/build-main"
}

src_configure() {
	# Determine sanitizer flags. This is necessary because the Makefile
	# purposely ignores CFLAGS from the environment. So we collect the
	# sanitizer flags and pass just them to the Makefile explicitly.
	SANITIZER_CFLAGS=
	append-flags() {
		SANITIZER_CFLAGS+=" $*"
	}
	sanitizers-setup-env
	if use_sanitizers; then
		# Disable alignment sanitization, https://crbug.com/1015908 .
		SANITIZER_CFLAGS+=" -fno-sanitize=alignment"

		# Run sanitizers with useful log output.
		SANITIZER_CFLAGS+=" -DVBOOT_DEBUG"

		# Suppressions for unit tests.
		if use test; then
			# Do not check memory leaks or odr violations in address sanitizer.
			# https://crbug.com/1015908 .
			export ASAN_OPTIONS+=":detect_leaks=0:detect_odr_violation=0:"
			# Suppress array bound checks, https://crbug.com/1082636 .
			SANITIZER_CFLAGS+=" -fno-sanitize=array-bounds"
		fi
	fi
	cros-debug-add-NDEBUG
	default
}

vemake() {
	emake \
		SRCDIR="${S}" \
		LIBDIR="$(get_libdir)" \
		ARCH=$(tc-arch) \
		SDK_BUILD=$(usev cros_host) \
		TPM2_MODE=$(usev tpm2) \
		PD_SYNC=$(usev pd_sync) \
		DEV_DEBUG_FORCE=$(usev dev_debug_force) \
		TPM2_SIMULATOR="$(usev tpm2_simulator)" \
		VTPM_PROXY="$(usev vtpm_proxy)" \
		FUZZ_FLAGS="${SANITIZER_CFLAGS}" \
		"$@"
}

src_compile() {
	mkdir "$(get_build_dir)"
	tc-export CC AR CXX PKG_CONFIG
	# vboot_reference knows the flags to use
	unset CFLAGS
	vemake BUILD="$(get_build_dir)" all $(usex fuzzer fuzzers '')
}

src_test() {
	! use amd64 && ! use x86 && ewarn "Skipping unittests for non-x86" && return 0
	vemake BUILD="$(get_build_dir)" runtests
}

src_install() {
	einfo "Installing programs"
	vemake \
		BUILD="$(get_build_dir)" \
		DESTDIR="${D}" \
		install install_dev

	if use tpmtests; then
		into /usr
		# copy files starting with tpmtest, but skip .d files.
		dobin "$(get_build_dir)"/tests/tpm_lite/tpmtest*[^.]?
		dobin "$(get_build_dir)"/utility/tpm_set_readsrkpub
	fi

	if use fuzzer; then
		einfo "Installing fuzzers"
		local fuzzer_component_id="167186"
		fuzzer_install "${S}"/OWNERS "$(get_build_dir)"/tests/cgpt_fuzzer \
			--comp "${fuzzer_component_id}"
		fuzzer_install "${S}"/OWNERS "$(get_build_dir)"/tests/vb2_keyblock_fuzzer \
			--comp "${fuzzer_component_id}"
		fuzzer_install "${S}"/OWNERS "$(get_build_dir)"/tests/vb2_preamble_fuzzer \
			--comp "${fuzzer_component_id}"
	fi
}

PATCHES=( "${FILESDIR}/force_set_vm.patch" )
