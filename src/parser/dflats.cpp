/*
 * Copyright 2014 Google Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "flatbuffers/idl.h"
#include "flatbuffers/code_generators.h"

#include <list>

static void Warn(const std::string &warn, bool show_exe_name = true) {
  printf("%s", warn.c_str());
}

static void Error(const std::string &err, bool usage = false,
                         bool show_exe_name = true) {
  printf("%s", err.c_str());
}

static void ParseFile(
    flatbuffers::Parser &parser, const std::string &filename,
    const std::string &contents,
    std::vector<const char *> &include_directories) {
  auto local_include_directory = flatbuffers::StripFileName(filename);
  include_directories.push_back(local_include_directory.c_str());
  include_directories.push_back(nullptr);
  if (!parser.Parse(contents.c_str(), &include_directories[0],
                    filename.c_str())) {
    Error(parser.error_, false, false);
  }
  if (!parser.error_.empty()) { Warn(parser.error_, false); }
  include_directories.pop_back();
  include_directories.pop_back();
}

static const char *idl_types[] = {
#define FLATBUFFERS_TD(ENUM, IDLTYPE, ...) IDLTYPE,
    FLATBUFFERS_GEN_TYPES(FLATBUFFERS_TD)
#undef FLATBUFFERS_TD
};

const std::string GenJSONType(const flatbuffers::Type &type) {
	if (type.base_type == flatbuffers::BASE_TYPE_STRUCT) {
		return std::string("{\"type\": \"struct\", \"struct\": \"") + type.struct_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.struct_def->name, false)) + "\"}";
	} else if (flatbuffers::IsSeries(type)) {
		if (type.element == flatbuffers::BASE_TYPE_STRUCT) {
			return std::string("{\"type\": \"vector\", \"element\": {\"type\": \"struct\", \"struct\": \"") + type.struct_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.struct_def->name, false)) + "\"}}";
		} else if (type.element == flatbuffers::BASE_TYPE_UNION) {
			return std::string("{\"type\": \"vector\", \"element\": {\"type\": \"union\", \"union\": \"") + type.enum_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.enum_def->name, false)) + "\"}}";
		} else if (type.element == flatbuffers::BASE_TYPE_UTYPE) {
			return std::string("{\"type\": \"vector\", \"element\": {\"type\": \"utype\", \"utype\": \"") + type.enum_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.enum_def->name, false)) + "\"}}";
		} else if (type.enum_def) {
			return std::string("{\"type\": \"vector\", \"element\": {\"type\": \"enum\", \"enum\": \"") + type.enum_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.enum_def->name, false)) + "\"}}";
		} else if (type.element == flatbuffers::BASE_TYPE_VECTOR || type.element == flatbuffers::BASE_TYPE_ARRAY) {
			exit(-1);
		} else {
			return std::string("{\"type\": \"vector\", \"element\": {\"type\": \"") + idl_types[type.element] + "\"}}";
		}
	} else if (flatbuffers::IsUnion(type)) {
		if (type.base_type == flatbuffers::BASE_TYPE_UTYPE) {
			return std::string("{\"type\": \"utype\", \"utype\": \"") + type.enum_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.enum_def->name, false)) + "\"}";
		} else if (type.base_type == flatbuffers::BASE_TYPE_UNION) {
			return std::string("{\"type\": \"union\", \"union\": \"") + type.enum_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.enum_def->name, false)) + "\"}";
		} else {
			exit(-1);
		}
	} else if (flatbuffers::IsEnum(type)) {
		return std::string("{\"type\": \"enum\", \"enum\": \"") + type.enum_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(type.enum_def->name, false)) + "\"}";
	} else {
		return std::string("{\"type\": \"") + idl_types[type.base_type] + "\"}";
	}
}

const std::string GenNamespace(const flatbuffers::Namespace &ns) {
	std::string json = "";
	for (auto it = ns.components.begin(); it != ns.components.end(); ++it) {
		if (it == ns.components.begin()) {
			json += "\"" + *it + "\"";
		} else {
			json += ", \"" + *it + "\"";
		}
	}
	return json;
}

const std::string GenAttributes(const flatbuffers::SymbolTable<flatbuffers::Value> &attributes) {
	std::string json = "\"attributes\": [";
	for (auto it = attributes.dict.begin(); it != attributes.dict.end(); ++it) {
		auto key = it->first;
		auto value = it->second;
		json += "{\"" + key + "\": \"" + value->constant + "\"}, ";
	}
	if (attributes.dict.size() > 0) {
		json = json.substr(0, json.size() - 2) + "]";
	} else {
		json = json + "]";
	}
	return json;
}

const std::string GenUnion(const flatbuffers::EnumDef &enum_def) {
	std::string json = std::string("{\"is_union\": ") + (enum_def.is_union ? "true" : "false") + ", ";
	json += "\"name\": \"" + flatbuffers::MakeCamel(enum_def.name, false) + "\", ";
	json += "\"generated\": ";
	json += (enum_def.generated ? "true, " : "false, ");
	json += "\"namespace\": [" + GenNamespace(*enum_def.defined_namespace) + "], ";
	if (!enum_def.is_union) {
		json += std::string("\"underlying_type\": \"") + idl_types[enum_def.underlying_type.base_type] + "\", ";
	}
	json += "\"fields\": [";
	const auto &vals = enum_def.Vals();
	for (auto it = vals.begin(); it != vals.end(); ++it) {
		const auto &enum_val = **it;
		if (enum_val.union_type.struct_def) {
			json += "{\"name\": \"" + flatbuffers::MakeCamel(enum_val.name, false) + "\", \"type\": \"struct\", \"struct\": \"" + enum_val.union_type.struct_def->defined_namespace->GetFullyQualifiedName(flatbuffers::MakeCamel(enum_val.union_type.struct_def->name, false)) + "\", \"value\": " + enum_def.ToString(enum_val) + "}, ";
		} else {
			json += "{\"name\": \"" + flatbuffers::MakeCamel(enum_val.name, false) + "\", \"type\": \"\", \"value\": " + enum_def.ToString(enum_val) + "}, ";
		}
	}
	if (vals.size() > 0) {
		json = json.substr(0, json.size() - 2) + "]}";
	} else {
		json = json + "]}";
	}
	return json;
}

const std::string GenStruct(const flatbuffers::StructDef &struct_def) {
	std::string json = std::string("{\"fixed\": ") + (struct_def.fixed ? "true" : "false") + ", ";
	json += "\"name\": \"" + flatbuffers::MakeCamel(struct_def.name, false) + "\", ";
	json += "\"generated\": ";
	json += (struct_def.generated ? "true, " : "false, ");
	json += "\"namespace\": [" + GenNamespace(*struct_def.defined_namespace) + "], ";
	json += GenAttributes(struct_def.attributes) + ", ";
	json += "\"fields\": [";
	for (auto it = struct_def.fields.vec.begin(); it != struct_def.fields.vec.end(); ++it) {
		const auto &field_def = **it;
		if (field_def.value.constant != "0") {
			json += "{\"name\": \"" + flatbuffers::MakeCamel(field_def.name, false) + "\", \"deprecated\": " + (field_def.deprecated ? "true" : "false") + ", \"type\": " + GenJSONType(field_def.value.type) + ", \"offset\": " + std::to_string(field_def.value.offset) + ", \"default\": \"" + field_def.value.constant + "\", " + GenAttributes(field_def.attributes) + "}, ";
		} else {
			json += "{\"name\": \"" + flatbuffers::MakeCamel(field_def.name, false) + "\", \"deprecated\": " + (field_def.deprecated ? "true" : "false") + ", \"type\": " + GenJSONType(field_def.value.type) + ", \"offset\": " + std::to_string(field_def.value.offset) + ", " + GenAttributes(field_def.attributes) + "}, ";
		}
	}
	if (struct_def.fields.vec.size() > 0) {
		json = json.substr(0, json.size() - 2) + "]}";
	} else {
		json = json + "]}";
	}
	return json;
}

static void GenerateJSONAdapter(const flatbuffers::Parser &parser, const std::string &path, const std::string &filebase) {
	std::string json = "{\"enums\": [";
	for (auto it = parser.enums_.vec.begin(); it != parser.enums_.vec.end(); ++it) {
		const auto &enum_def = **it;
		json += GenUnion(enum_def) + ", ";
	}
	if (parser.enums_.vec.size() > 0) {
		json = json.substr(0, json.size() - 2) + "], \"structs\": [";
	} else {
		json = json + "], \"structs\": [";
	}
	for (auto it = parser.structs_.vec.begin(); it != parser.structs_.vec.end(); ++it) {
		const auto &struct_def = **it;
		if (struct_def.fixed) {
			json += GenStruct(struct_def) + ", ";
		}
	}
	for (auto it = parser.structs_.vec.begin(); it != parser.structs_.vec.end(); ++it) {
		const auto &struct_def = **it;
		if (!struct_def.fixed) {
			json += GenStruct(struct_def) + ", ";
		}
	}
	if (parser.root_struct_def_) {
		if (parser.structs_.vec.size() > 0) {
			json = json.substr(0, json.size() - 2) + "], \"root\": {\"namespace\": [" + GenNamespace(*parser.root_struct_def_->defined_namespace) + "], \"name\": \"" + flatbuffers::MakeCamel(parser.root_struct_def_->name, false) + "\"}}";
		} else {
			json = json + "], \"root\": {\"namespace\": [" + GenNamespace(*parser.root_struct_def_->defined_namespace) + "], \"name\": \"" + flatbuffers::MakeCamel(parser.root_struct_def_->name, false) + "\"}}";
		}
	} else {
		json = json + "]}";
	}
	auto filename = path + "/" + filebase + "_generated.json";
	flatbuffers::SaveFile(filename.c_str(), json, false);
}

static void InsertNamespace(flatbuffers::Parser &parser, const std::string &given) {
	for (auto it = parser.enums_.vec.begin(); it != parser.enums_.vec.end(); ++it) {
		auto &enum_def = **it;
		if (enum_def.defined_namespace->components.size() < 1 || enum_def.defined_namespace->components[0].rfind(given, 0) != 0) {
			enum_def.defined_namespace->components.insert(enum_def.defined_namespace->components.begin(), given);
		}
	}
	for (auto it = parser.structs_.vec.begin(); it != parser.structs_.vec.end(); ++it) {
		auto &struct_def = **it;
		if (struct_def.defined_namespace->components.size() < 1 || struct_def.defined_namespace->components[0].rfind(given, 0) != 0) {
			struct_def.defined_namespace->components.insert(struct_def.defined_namespace->components.begin(), given);
		}
	}
}

int main(int argc, const char **argv) {
  flatbuffers::IDLOptions opts;
  std::string output_path;

  std::vector<std::string> filenames;
  std::list<std::string> include_directories_storage;
  std::vector<const char *> include_directories;

  for (int argi = 1; argi < argc; argi++) {
    std::string arg = argv[argi];
    if (arg[0] == '-') {
      if (filenames.size() && arg[1] != '-')
        Error("invalid option location: " + arg, true);
      if (arg == "-o") {
        if (++argi >= argc) Error("missing path following: " + arg, true);
        output_path = flatbuffers::ConCatPathFileName(
            flatbuffers::PosixPath(argv[argi]), "");
      } else if (arg == "-I") {
        if (++argi >= argc) Error("missing path following: " + arg, true);
        include_directories_storage.push_back(
            flatbuffers::PosixPath(argv[argi]));
        include_directories.push_back(
            include_directories_storage.back().c_str());
      }
    } else {
      filenames.push_back(flatbuffers::PosixPath(argv[argi]));
    }
  }

  if (!filenames.size()) Error("missing input files", false, true);
  opts.lang_to_generate |= flatbuffers::IDLOptions::kSwift;

  std::unique_ptr<flatbuffers::Parser> parser(nullptr);

  for (auto file_it = filenames.begin(); file_it != filenames.end();
       ++file_it) {
    auto &filename = *file_it;
    std::string contents;
    if (!flatbuffers::LoadFile(filename.c_str(), true, &contents)) {
      Error("unable to load file: " + filename);
    }
    auto ext = flatbuffers::GetExtension(filename);
    assert(ext == "fbs");
    // Check if file contains 0 bytes.
    if (contents.length() != strlen(contents.c_str())) {
      Error("input file appears to be binary: " + filename, true);
    }
    // If we're processing multiple schemas, make sure to start each
    // one from scratch. If it depends on previous schemas it must do
    // so explicitly using an include.
    parser.reset(new flatbuffers::Parser(opts));
    parser->known_attributes_["primary"] = true;
    parser->known_attributes_["indexed"] = true;
    parser->known_attributes_["unique"] = true;
    parser->known_attributes_["v"] = true;
    ParseFile(*parser.get(), filename, contents, include_directories);

    if (parser->root_struct_def_ && parser->root_struct_def_->fixed) {
      Error("root type must be a table");
    }

    std::string filebase =
        flatbuffers::StripPath(flatbuffers::StripExtension(filename));

    flatbuffers::EnsureDirExists(output_path);
    GenerateJSONAdapter(*parser.get(), output_path, filebase);
    // Attach additional namespace to it.
    InsertNamespace(*parser.get(), "zzz_DflatGen");
    flatbuffers::GenerateSwift(*parser.get(), output_path, filebase);

    // We do not want to generate code for the definitions in this file
    // in any files coming up next.
    parser->MarkGenerated();
  }
  return 0;
}
