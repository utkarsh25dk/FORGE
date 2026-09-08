#!/usr/bin/env python3
"""Regenerates FORGE.xcodeproj/project.pbxproj by scanning the FORGE/ and ForgeWidget/ source trees.
Rerun any time files are added/removed: python3 generate_project.py
"""
import os
import uuid
import hashlib
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC_ROOT = os.path.join(ROOT, "FORGE")
WIDGET_SRC_ROOT = os.path.join(ROOT, "ForgeWidget")
PROJECT_NAME = "FORGE"
BUNDLE_ID = "com.utkarsh25rk.forge"
WIDGET_TARGET_NAME = "ForgeWidgetExtension"
WIDGET_BUNDLE_ID = "com.utkarsh25rk.forge.widget"
DEPLOYMENT_TARGET = "26.0"

def new_id(key=None):
    """A stable 24-hex-char object id.

    Derived from `key` rather than random, so regenerating with no source
    changes reproduces the pbxproj byte for byte and adding one file touches
    only that file's lines. With uuid4 every regeneration rewrote the whole
    project file, burying real changes in a thousand-line diff.
    """
    if key is None:
        return uuid.uuid4().hex[:24].upper()
    return hashlib.sha1(key.encode("utf-8")).hexdigest()[:24].upper()

# ---- collect files ----
SWIFT_EXT = {".swift"}
RESOURCE_EXT = {".ttf", ".otf"}

class Node:
    def __init__(self, name, path, is_dir):
        self.name = name
        self.path = path
        self.is_dir = is_dir
        self.children = []
        self.id = new_id("node:" + os.path.relpath(path, ROOT))

def build_tree(dir_path, name):
    node = Node(name, dir_path, True)
    for entry in sorted(os.listdir(dir_path)):
        if entry.startswith("."):
            continue
        full = os.path.join(dir_path, entry)
        if os.path.isdir(full):
            if entry.endswith(".xcassets"):
                node.children.append(Node(entry, full, False))  # treat as single ref (folder.assetcatalog)
            else:
                node.children.append(build_tree(full, entry))
        else:
            node.children.append(Node(entry, full, False))
    return node

def walk(node, swift_out, resource_out, prefix=""):
    for child in node.children:
        rel = os.path.join(prefix, child.name) if prefix else child.name
        if child.is_dir:
            walk(child, swift_out, resource_out, rel)
        else:
            ext = os.path.splitext(child.name)[1]
            if ext in SWIFT_EXT:
                swift_out.append((child.id, child.name, rel))
            elif child.name.endswith(".xcassets"):
                resource_out.append((child.id, child.name, rel, "folder.assetcatalog"))
            elif ext in RESOURCE_EXT:
                resource_out.append((child.id, child.name, rel, "file"))
            else:
                pass  # Info.plist / entitlements: referenced by literal path in build settings, not a build phase

tree = build_tree(SRC_ROOT, "FORGE")
widget_tree = build_tree(WIDGET_SRC_ROOT, "ForgeWidget")

swift_files = []      # (id, name, relpath) — app target
resource_files = []   # (id, name, relpath, filetype) — app target
widget_swift_files = []
widget_resource_files = []

walk(tree, swift_files, resource_files)
walk(widget_tree, widget_swift_files, widget_resource_files)

# Shared file compiled into both targets: the app <-> widget snapshot bridge.
shared_snapshot_ref = next((f for f in swift_files if f[1] == "WidgetSnapshot.swift"), None)
if shared_snapshot_ref is None:
    sys.exit("WidgetSnapshot.swift not found under FORGE/ — required by the widget extension")
SHARED_SNAPSHOT_FILE_ID = shared_snapshot_ref[0]

# ---- ids ----
PBXPROJ_ID = new_id('PBXPROJ_ID')
MAIN_GROUP_ID = new_id('MAIN_GROUP_ID')
PRODUCTS_GROUP_ID = new_id('PRODUCTS_GROUP_ID')
APP_PRODUCT_REF_ID = new_id('APP_PRODUCT_REF_ID')
TARGET_ID = new_id('TARGET_ID')
NATIVE_TARGET_BUILD_CONFIG_LIST = new_id('NATIVE_TARGET_BUILD_CONFIG_LIST')
PROJECT_BUILD_CONFIG_LIST = new_id('PROJECT_BUILD_CONFIG_LIST')
DEBUG_PROJ_CFG = new_id('DEBUG_PROJ_CFG')
RELEASE_PROJ_CFG = new_id('RELEASE_PROJ_CFG')
DEBUG_TARGET_CFG = new_id('DEBUG_TARGET_CFG')
RELEASE_TARGET_CFG = new_id('RELEASE_TARGET_CFG')
SOURCES_PHASE_ID = new_id('SOURCES_PHASE_ID')
RESOURCES_PHASE_ID = new_id('RESOURCES_PHASE_ID')
FRAMEWORKS_PHASE_ID = new_id('FRAMEWORKS_PHASE_ID')

WIDGET_PRODUCT_REF_ID = new_id('WIDGET_PRODUCT_REF_ID')
WIDGET_TARGET_ID = new_id('WIDGET_TARGET_ID')
WIDGET_NATIVE_TARGET_BUILD_CONFIG_LIST = new_id('WIDGET_NATIVE_TARGET_BUILD_CONFIG_LIST')
WIDGET_DEBUG_TARGET_CFG = new_id('WIDGET_DEBUG_TARGET_CFG')
WIDGET_RELEASE_TARGET_CFG = new_id('WIDGET_RELEASE_TARGET_CFG')
WIDGET_SOURCES_PHASE_ID = new_id('WIDGET_SOURCES_PHASE_ID')
WIDGET_RESOURCES_PHASE_ID = new_id('WIDGET_RESOURCES_PHASE_ID')
WIDGET_FRAMEWORKS_PHASE_ID = new_id('WIDGET_FRAMEWORKS_PHASE_ID')
EMBED_WIDGET_PHASE_ID = new_id('EMBED_WIDGET_PHASE_ID')
WIDGET_EMBED_BUILD_FILE_ID = new_id('WIDGET_EMBED_BUILD_FILE_ID')
WIDGET_CONTAINER_ITEM_PROXY_ID = new_id('WIDGET_CONTAINER_ITEM_PROXY_ID')
WIDGET_TARGET_DEPENDENCY_ID = new_id('WIDGET_TARGET_DEPENDENCY_ID')
SHARED_SNAPSHOT_WIDGET_BUILD_FILE_ID = new_id('SHARED_SNAPSHOT_WIDGET_BUILD_FILE_ID')

# group id for each source root must match tree.id (set below) so PBXGroup
# references from the main group resolve to the actual emitted group entry.
FORGE_GROUP_ID = tree.id
WIDGET_GROUP_ID = widget_tree.id

build_files_swift = []  # (buildFileId, fileRefId)
build_files_resource = []
widget_build_files_swift = []
widget_build_files_resource = []

for (fid, name, rel) in swift_files:
    build_files_swift.append((new_id("buildfile:build_files_swift:" + rel), fid))
for (fid, name, rel, ftype) in resource_files:
    build_files_resource.append((new_id("buildfile:build_files_resource:" + rel), fid))
for (fid, name, rel) in widget_swift_files:
    widget_build_files_swift.append((new_id("buildfile:widget_build_files_swift:" + rel), fid))
for (fid, name, rel, ftype) in widget_resource_files:
    widget_build_files_resource.append((new_id("buildfile:widget_build_files_resource:" + rel), fid))

# recursive group builder producing PBXGroup entries text + mapping
group_entries = []  # list of pbxproj text blocks

def file_type_for(name, is_assets, is_resource_other):
    if name.endswith(".swift"):
        return "sourcecode.swift"
    if name.endswith(".xcassets"):
        return "folder.assetcatalog"
    if name.endswith(".ttf") or name.endswith(".otf"):
        return None  # let Xcode infer -> use 'file' explicit type omitted, set explicitFileType absent, use lastKnownFileType file
    if name == "Info.plist" or name.endswith(".entitlements"):
        return "text.plist.xml"
    return "text"

def emit_group(node, name_for_group):
    """Emit PBXGroup for this node's children, return the group id (node.id)."""
    child_refs = []
    for child in node.children:
        if child.is_dir:
            emit_group(child, child.name)
            child_refs.append(child.id)
        else:
            ft = file_type_for(child.name, False, False)
            if ft:
                group_entries.append(
                    f'\t\t{child.id} /* {child.name} */ = {{isa = PBXFileReference; lastKnownFileType = {ft}; path = {child.name}; sourceTree = "<group>"; }};'
                )
            else:
                group_entries.append(
                    f'\t\t{child.id} /* {child.name} */ = {{isa = PBXFileReference; lastKnownFileType = file; path = {child.name}; sourceTree = "<group>"; }};'
                )
            child_refs.append(child.id)
    # build children list with comments
    lines = []
    for child in node.children:
        lines.append(f"\t\t\t\t{child.id} /* {child.name} */,")
    children_block = "\n".join(lines)
    group_entries.append(
        f'\t\t{node.id} /* {name_for_group} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{children_block}\n\t\t\t);\n\t\t\tpath = {name_for_group};\n\t\t\tsourceTree = "<group>";\n\t\t}};'
    )
    return node.id

emit_group(tree, "FORGE")
emit_group(widget_tree, "ForgeWidget")

file_refs_text = "\n".join(group_entries)

sources_build_file_entries = []
for (bfid, fid), (ffid, name, rel) in zip(build_files_swift, swift_files):
    sources_build_file_entries.append(f'\t\t{bfid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};')

resources_build_file_entries = []
for (bfid, fid), (ffid, name, rel, ftype) in zip(build_files_resource, resource_files):
    resources_build_file_entries.append(f'\t\t{bfid} /* {name} in Resources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};')

widget_sources_build_file_entries = []
for (bfid, fid), (ffid, name, rel) in zip(widget_build_files_swift, widget_swift_files):
    widget_sources_build_file_entries.append(f'\t\t{bfid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};')
widget_sources_build_file_entries.append(
    f'\t\t{SHARED_SNAPSHOT_WIDGET_BUILD_FILE_ID} /* WidgetSnapshot.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {SHARED_SNAPSHOT_FILE_ID} /* WidgetSnapshot.swift */; }};'
)

widget_resources_build_file_entries = []
for (bfid, fid), (ffid, name, rel, ftype) in zip(widget_build_files_resource, widget_resource_files):
    widget_resources_build_file_entries.append(f'\t\t{bfid} /* {name} in Resources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};')

embed_widget_build_file_entry = (
    f'\t\t{WIDGET_EMBED_BUILD_FILE_ID} /* {WIDGET_TARGET_NAME}.appex in Embed Foundation Extensions */ = '
    f'{{isa = PBXBuildFile; fileRef = {WIDGET_PRODUCT_REF_ID} /* {WIDGET_TARGET_NAME}.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};'
)

sources_phase_files = "\n".join(f"\t\t\t\t{bfid} /* {name} in Sources */," for (bfid, fid), (ffid, name, rel) in zip(build_files_swift, swift_files))
resources_phase_files = "\n".join(f"\t\t\t\t{bfid} /* {name} in Resources */," for (bfid, fid), (ffid, name, rel, ftype) in zip(build_files_resource, resource_files))

widget_sources_phase_files = "\n".join(f"\t\t\t\t{bfid} /* {name} in Sources */," for (bfid, fid), (ffid, name, rel) in zip(widget_build_files_swift, widget_swift_files))
widget_sources_phase_files += f"\n\t\t\t\t{SHARED_SNAPSHOT_WIDGET_BUILD_FILE_ID} /* WidgetSnapshot.swift in Sources */,"
widget_resources_phase_files = "\n".join(f"\t\t\t\t{bfid} /* {name} in Resources */," for (bfid, fid), (ffid, name, rel, ftype) in zip(widget_build_files_resource, widget_resource_files))

pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(sources_build_file_entries)}
{chr(10).join(resources_build_file_entries)}
{chr(10).join(widget_sources_build_file_entries)}
{chr(10).join(widget_resources_build_file_entries)}
{embed_widget_build_file_entry}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
\t\t{WIDGET_CONTAINER_ITEM_PROXY_ID} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {PBXPROJ_ID} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {WIDGET_TARGET_ID};
\t\t\tremoteInfo = {WIDGET_TARGET_NAME};
\t\t}};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
\t\t{EMBED_WIDGET_PHASE_ID} /* Embed Foundation Extensions */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "";
\t\t\tdstSubfolderSpec = 13;
\t\t\tfiles = (
\t\t\t\t{WIDGET_EMBED_BUILD_FILE_ID} /* {WIDGET_TARGET_NAME}.appex in Embed Foundation Extensions */,
\t\t\t);
\t\t\tname = "Embed Foundation Extensions";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
\t\t{APP_PRODUCT_REF_ID} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{WIDGET_PRODUCT_REF_ID} /* {WIDGET_TARGET_NAME}.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = {WIDGET_TARGET_NAME}.appex; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{new_id("fileref:Info.plist")} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
{file_refs_text}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{FRAMEWORKS_PHASE_ID} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{WIDGET_FRAMEWORKS_PHASE_ID} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{MAIN_GROUP_ID} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{FORGE_GROUP_ID} /* FORGE */,
\t\t\t\t{WIDGET_GROUP_ID} /* ForgeWidget */,
\t\t\t\t{PRODUCTS_GROUP_ID} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{PRODUCTS_GROUP_ID} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{APP_PRODUCT_REF_ID} /* {PROJECT_NAME}.app */,
\t\t\t\t{WIDGET_PRODUCT_REF_ID} /* {WIDGET_TARGET_NAME}.appex */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{TARGET_ID} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {NATIVE_TARGET_BUILD_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */;
\t\t\tbuildPhases = (
\t\t\t\t{SOURCES_PHASE_ID} /* Sources */,
\t\t\t\t{FRAMEWORKS_PHASE_ID} /* Frameworks */,
\t\t\t\t{RESOURCES_PHASE_ID} /* Resources */,
\t\t\t\t{EMBED_WIDGET_PHASE_ID} /* Embed Foundation Extensions */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{WIDGET_TARGET_DEPENDENCY_ID} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = {PROJECT_NAME};
\t\t\tproductName = {PROJECT_NAME};
\t\t\tproductReference = {APP_PRODUCT_REF_ID} /* {PROJECT_NAME}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{WIDGET_TARGET_ID} /* {WIDGET_TARGET_NAME} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {WIDGET_NATIVE_TARGET_BUILD_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "{WIDGET_TARGET_NAME}" */;
\t\t\tbuildPhases = (
\t\t\t\t{WIDGET_SOURCES_PHASE_ID} /* Sources */,
\t\t\t\t{WIDGET_FRAMEWORKS_PHASE_ID} /* Frameworks */,
\t\t\t\t{WIDGET_RESOURCES_PHASE_ID} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {WIDGET_TARGET_NAME};
\t\t\tproductName = {WIDGET_TARGET_NAME};
\t\t\tproductReference = {WIDGET_PRODUCT_REF_ID} /* {WIDGET_TARGET_NAME}.appex */;
\t\t\tproductType = "com.apple.product-type.app-extension";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PBXPROJ_ID} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1540;
\t\t\t\tLastUpgradeCheck = 1540;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{TARGET_ID} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.4;
\t\t\t\t\t}};
\t\t\t\t\t{WIDGET_TARGET_ID} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.4;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {PROJECT_BUILD_CONFIG_LIST} /* Build configuration list for PBXProject "{PROJECT_NAME}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {MAIN_GROUP_ID};
\t\t\tproductRefGroup = {PRODUCTS_GROUP_ID} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{TARGET_ID} /* {PROJECT_NAME} */,
\t\t\t\t{WIDGET_TARGET_ID} /* {WIDGET_TARGET_NAME} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{RESOURCES_PHASE_ID} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{resources_phase_files}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{WIDGET_RESOURCES_PHASE_ID} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{widget_resources_phase_files}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{SOURCES_PHASE_ID} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{sources_phase_files}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{WIDGET_SOURCES_PHASE_ID} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{widget_sources_phase_files}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
\t\t{WIDGET_TARGET_DEPENDENCY_ID} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {WIDGET_TARGET_ID} /* {WIDGET_TARGET_NAME} */;
\t\t\ttargetProxy = {WIDGET_CONTAINER_ITEM_PROXY_ID} /* PBXContainerItemProxy */;
\t\t}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\t{DEBUG_PROJ_CFG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOYMENT_TARGET};
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_PROJ_CFG} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOYMENT_TARGET};
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{DEBUG_TARGET_CFG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = FORGE/FORGE.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = FORGE/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_TARGET_CFG} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = FORGE/FORGE.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = FORGE/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{WIDGET_DEBUG_TARGET_CFG} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = ForgeWidget/ForgeWidget.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = ForgeWidget/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOYMENT_TARGET};
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {WIDGET_BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{WIDGET_RELEASE_TARGET_CFG} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = ForgeWidget/ForgeWidget.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = ForgeWidget/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOYMENT_TARGET};
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {WIDGET_BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{PROJECT_BUILD_CONFIG_LIST} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_PROJ_CFG} /* Debug */,
\t\t\t\t{RELEASE_PROJ_CFG} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{NATIVE_TARGET_BUILD_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_TARGET_CFG} /* Debug */,
\t\t\t\t{RELEASE_TARGET_CFG} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{WIDGET_NATIVE_TARGET_BUILD_CONFIG_LIST} /* Build configuration list for PBXNativeTarget "{WIDGET_TARGET_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{WIDGET_DEBUG_TARGET_CFG} /* Debug */,
\t\t\t\t{WIDGET_RELEASE_TARGET_CFG} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {PBXPROJ_ID} /* Project object */;
}}
"""

xcodeproj_dir = os.path.join(ROOT, f"{PROJECT_NAME}.xcodeproj")
os.makedirs(xcodeproj_dir, exist_ok=True)
with open(os.path.join(xcodeproj_dir, "project.pbxproj"), "w") as f:
    f.write(pbxproj)

# minimal workspace contents + shared scheme so xcodebuild -scheme works
workspace_dir = os.path.join(xcodeproj_dir, "project.xcworkspace")
os.makedirs(workspace_dir, exist_ok=True)
with open(os.path.join(workspace_dir, "contents.xcworkspacedata"), "w") as f:
    f.write('''<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
''')

schemes_dir = os.path.join(xcodeproj_dir, "xcshareddata", "xcschemes")
os.makedirs(schemes_dir, exist_ok=True)
scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2660"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{TARGET_ID}"
               BuildableName = "{PROJECT_NAME}.app"
               BlueprintName = "{PROJECT_NAME}"
               ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{TARGET_ID}"
            BuildableName = "{PROJECT_NAME}.app"
            BlueprintName = "{PROJECT_NAME}"
            ReferencedContainer = "container:{PROJECT_NAME}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
'''
with open(os.path.join(schemes_dir, f"{PROJECT_NAME}.xcscheme"), "w") as f:
    f.write(scheme)

print(f"Generated {len(swift_files)} app swift files, {len(resource_files)} app resources.")
print(f"Generated {len(widget_swift_files)} widget swift files, {len(widget_resource_files)} widget resources.")
print("project.pbxproj written to", xcodeproj_dir)
