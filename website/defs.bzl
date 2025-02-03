load("@aspect_rules_swc//swc:defs.bzl", "swc")
load("@aspect_rules_ts//ts:defs.bzl", "ts_project")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@npm//:tsconfig-to-swcconfig/package_json.bzl", tsconfig_to_swcconfig = "bin")

def type_check(name, srcs, tsconfig):
    tsconfig_to_swcconfig.tsconfig_to_swcconfig(
        name = "%s_write_swcrc" % name,
        srcs = [
            tsconfig,
        ],
        args = [
            "--filename",
            "$(location %s)" % tsconfig,
        ],
        stdout = ".%s_swcrc" % name,
    )

    ts_project(
        name = "%s_ts" % name,
        srcs = srcs,
        no_emit = True,
        transpiler = partial.make(
            swc,
            swcrc = ":.%s_swcrc" % name,
        ),
        tsconfig = tsconfig,
    )
