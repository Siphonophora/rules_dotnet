"""
Rules for importing assemblies for .NET frameworks.
"""

load(
    "//dotnet/private:common.bzl",
    "collect_transitive_info",
)
load("//dotnet/private:providers.bzl", "AnyTargetFrameworkInfo", "DotnetAssemblyInfo")

def _import_library(ctx):
    (_irefs, prefs, analyzers, runfiles) = collect_transitive_info(ctx.label.name, ctx.attr.deps)

    return DotnetAssemblyInfo(
        name = ctx.label.name,
        version = ctx.attr.version,
        libs = ctx.files.libs,
        analyzers = ctx.files.analyzers,
        data = ctx.files.data,
        prefs = ctx.files.refs or ctx.files.libs,
        irefs = ctx.files.refs or ctx.files.libs,
        internals_visible_to = [],
        deps = ctx.attr.deps,
        # todo is this one needed?
        # transitive = depset(direct = ctx.attr.deps, transitive = [a[DotnetAssemblyInfo].transitive for a in ctx.attr.deps]),
        transitive_prefs = prefs,
        transitive_analyzers = analyzers,
        transitive_runfiles = runfiles,
    )

import_library = rule(
    _import_library,
    doc = "Creates a target for a static C# DLL for a specific target framework",
    attrs = {
        # todo where is this required?
        "version": attr.string(),
        "libs": attr.label_list(
            doc = "static DLLs",
            allow_files = True, # [".dll"] currently does not work with empty file groups
            allow_empty = True,
        ),
        "analyzers": attr.label_list(
            doc = "static DLLs",
            allow_files = True, # [".dll"] currently does not work with empty file groups
            allow_empty = True,
        ),
        # todo maybe add pdb's as data.
        "refs": attr.label_list(
            doc = "metadata-only DLLs, suitable for compiling against but not running",
            allow_files = True, # [".dll"] currently does not work with empty file groups
            allow_empty = True,
        ),
        # arent these just deps?
        # "native_dlls": attr.label_list(
        #     doc = "A list of native dlls, which while unreferenced, are required for running and compiling",
        #     allow_files = [".dll"],
        # ),
        "deps": attr.label_list(
            doc = "other DLLs that this DLL depends on.",
            providers = AnyTargetFrameworkInfo,
        ),
        "data": attr.label_list(
            doc = "Other files that this DLL depends on at runtime",
            allow_files = True,
        ),
    },
    executable = False,
)
