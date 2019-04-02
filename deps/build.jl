using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libmetis"], :libmetis),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/fredrikekre/METISBuilder/releases/download/v5.1.0-1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/METIS.v5.1.0.aarch64-linux-gnu.tar.gz", "3bfeb817f8885eaea90fe0e2a621fedf23b4b3bbc231e478f91167cc1e736f0a"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/METIS.v5.1.0.aarch64-linux-musl.tar.gz", "3d5be61bcfefc9df4f728084848a15df33a700a12f276ca4de7028f4c35c9c5b"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/METIS.v5.1.0.arm-linux-gnueabihf.tar.gz", "07dc074c2cba0a1773ac2eaf0d7d1c5aa47d0590caaf6ee4f5f1035fa862d3e4"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/METIS.v5.1.0.arm-linux-musleabihf.tar.gz", "84ad814ee7b4e6d16e9b706a34294965d877d4e27de58723c28ad3746811a891"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/METIS.v5.1.0.i686-linux-gnu.tar.gz", "853f55d267a5017381011165b8b056e0f10e8e8bde8b4dec12fa874887c22dd9"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/METIS.v5.1.0.i686-linux-musl.tar.gz", "d2bac254192e89bb765350abd33c7b49eff7f6208b2221d7170fb37a2b4d03bb"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/METIS.v5.1.0.powerpc64le-linux-gnu.tar.gz", "7c6f58f0abb52526029eac9bc1c0abbc086754fbb7972dbdf2d8b643c4a3652c"),
    MacOS(:x86_64) => ("$bin_prefix/METIS.v5.1.0.x86_64-apple-darwin14.tar.gz", "973e93a05a3ff9ed912a38319ab05c44cb96dbb789130138b5465221b317868f"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/METIS.v5.1.0.x86_64-linux-gnu.tar.gz", "60b99dc5703ba7d2afc92c297c60115ba8880cd3836abbbe1c97a99b1878f5f9"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/METIS.v5.1.0.x86_64-linux-musl.tar.gz", "6a34b0134685296454cb6810f3fbc21bbeb59944827f075b850927449b005f7e"),
    FreeBSD(:x86_64) => ("$bin_prefix/METIS.v5.1.0.x86_64-unknown-freebsd11.1.tar.gz", "3fbfeb1d339b687972b55b576b05bf7c7b4ec0002896806f09e5780b1cbc9704"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
