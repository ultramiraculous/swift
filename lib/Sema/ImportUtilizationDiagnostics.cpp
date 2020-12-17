//===--- ImportUtilizationDiagnostics.cpp - AST-Level Diagnostics ----------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// This file implements AST-level diagnostics.
//
//===----------------------------------------------------------------------===//

#include "ImportUtilizationDiagnostics.h"
#include "TypeCheckAvailability.h"
#include "TypeCheckConcurrency.h"
#include "TypeChecker.h"
#include "swift/AST/ASTWalker.h"
#include "swift/AST/ASTVisitor.h"
#include "swift/AST/EvaluatorDependencies.h"
#include "swift/AST/Import.h"
#include "swift/AST/ImportCache.h"
#include "swift/AST/NameLookup.h"
#include "swift/AST/NameLookupRequests.h"
#include "swift/AST/Pattern.h"
#include "swift/Basic/Defer.h"
#include "swift/Basic/SourceManager.h"
#include "swift/Basic/Statistic.h"
#include "swift/Basic/StringExtras.h"
#include "swift/Parse/Lexer.h"
#include "swift/Parse/Parser.h"
#include "swift/Sema/ConstraintSystem.h"
#include "swift/Sema/IDETypeChecking.h"
#include "llvm/ADT/MapVector.h"

#include "swift/AST/DiagnosticsSema.h"

#define DEBUG_TYPE "Sema"
using namespace swift;

using TypeSet = llvm::DenseSet<TypeDecl *>;
using TypesForModule = llvm::DenseMap<Identifier, TypeSet>;

using TypesForImport = llvm::DenseMap<ImportDecl *, TypeSet>;


bool importProvidesType(ImportDecl *import, TypeDecl *type) {
    if (import->getImportKind() != ImportKind::Module) {
        for (auto decl : import->getDecls()) {
            if (dyn_cast<TypeDecl>(decl) == type) {
                return true;
            }
        }
    } else {

    }
    
    return false;
}

namespace {

    class BoundTypeWalker : public TypeReprVisitor<BoundTypeWalker>, public ASTWalker {
        SourceFile *SF;
        TypesForModule &Results;
        TypesForImport &ImportResults;
        TypeSet SeenTypes;
        
        void recordBoundType(TypeDecl *type) {
            // Return early if we've already added this type to SeenTypes.
            if (SeenTypes.insert(type).second == false) {
                return;
            }
            
            auto &astContext = SF->getASTContext();
            auto &importCache = astContext.getImportCache();
            
//            type->dump();
            
            auto module = type->getModuleContext();
            
            auto name = type->ValueDecl::getName();
            Results[module->getName()].insert(type);
            
            for (auto decl : SF->getTopLevelDecls()) {
                auto import = dyn_cast<ImportDecl>(decl);
                if (!import) { continue; }
                
                if (importProvidesType(import, type)) {
                    ImportResults[import].insert(type);
                }
            }
            
            // Iterate through all access paths visible (from the top level or exported elsewhere) leading to the referenced module.
            // Assume this lookup is *actually* cached and not expensive to look up for every reference in the file.
//            auto paths = importCache.getAllVisibleAccessPaths(module, SF);
//            for (auto &path : paths) {
//                ImportedModule Module(path, module);
//                if (path.size() == 0) {
//                    Results[Module].insert(type);
//                } else {
//                    Module.importedModule
//                }
//
//                printf("");
//            }
        }

    public:
        BoundTypeWalker(SourceFile *SF, TypesForModule &Results, TypesForImport &ImportResults)
        : SF(SF), Results(Results), ImportResults(ImportResults) {}

        
      
        
      bool walkToTypeReprPre(TypeRepr *typeRepr) override {
          if (auto *idRepr = dyn_cast<IdentTypeRepr>(typeRepr)) {
              for (auto comp : idRepr->getComponentRange()) {
                  if (comp->isBound()) {
                      recordBoundType(comp->getBoundDecl());
                  }
              }
          }
            
        return true;
      }
    };
}

bool diagnoseUnusedImportDecl(ImportDecl *import, TypesForModule lookup);
bool diagnoseDuplicateImportDecl(ImportDecl *import, TypesForModule usageLookup);
bool diagnoseUnusedTestableAttribute(ImportDecl *import, TypesForModule usageLookup);

ImportedModule convert(ImportDecl *loadedImport) {
    return ImportedModule(loadedImport->getAccessPath(), loadedImport->getModule());
}


void swift::analyzeImportUtilization(SourceFile *SF) {
//    assert(SF->ASTStage >= SourceFile::TypeChecked &&
//           "Cannot analyze import utilization before typechecking.");
    
//    auto &ctx = SF->getASTContext();
    auto decls = SF->getTopLevelDecls();
    
    TypesForModule typesByModule;
    TypesForImport typesByImport;
    
    BoundTypeWalker Walker(SF, typesByModule, typesByImport);
    for (auto *decl : decls) {
        auto importDecl = dyn_cast<ImportDecl>(decl);
        if (importDecl)
          continue;
        
      decl->walk(Walker);
    }
        
    for (auto decl : decls) {
        auto import = dyn_cast<ImportDecl>(decl);
        if (!import) { continue; }
        
        if (diagnoseUnusedImportDecl(import, typesByModule)) {
            continue;
        }
        
        
        
        diagnoseUnusedTestableAttribute(import, typesByModule);
    }
    
}



bool diagnoseUnusedImportDecl(ImportDecl *import, TypesForModule usageLookup) {
    auto usedTypes = usageLookup[import->getModule()->getName()];
    if (usedTypes.size() != 0) {
        if (import->getImportKind() == ImportKind::Module) {
            return false;
        } else {
            for (auto decl : import->getDecls()) {
                if (auto typeDecl = dyn_cast<TypeDecl>(decl)) {
                    if (usedTypes.find(typeDecl) != usedTypes.end()) {
                        return false;
                    }
                }
            }
        }
    }
    
    // Diag unused
    import->getASTContext().Diags.diagnose(import, diag::sema_unused_import).fixItRemove(import->getSourceRange());
    
    return true;
}

bool diagnoseUnusedTestableAttribute(ImportDecl *import, TypesForModule usageLookup) {
    if (import->getAttrs() )
    
    auto usedTypes = usageLookup[import->getModule()->getName()];
    for (auto &type : usedTypes) {
        auto accessLevel = type->getFormalAccess();
        if (accessLevel < AccessLevel::Public) {
            // If any
            return false;
        }
    }
    
    
    
    import->getASTContext().Diags.diagnose(import, diag::sema_unnecessarily_testable).fixItRemove(import->getSourceRange());
    
}

//
//bool diagnoseUnusedTestableAttribute(ImportDecl *import, ReferenceLookup lookup) {
//    auto &refs = lookup[convert(import)];
//    
//    for (auto &ref : refs) {
//        auto accessLevel = ref.subject->getFormalAccess();
//        if (accessLevel < AccessLevel::Public) {
//            // If any
//            return false;
//        }
//    }
//    
//    // Diag unused @testable modifier
//    
////    diag.emplace(ctx.Diags.diagnose(I.importLoc,
////                 diag::sema_duplicate_import,
////                 accessPath));
//
//    
//    return true;
//}


/*
void DependencyVerifier::analyzeImportUtilization(const SourceFile *SF) {
  llvm::DenseMap<ImportPath::Access, DependencyCollector::ReferenceSet> referencesByAccessPath;

  auto &Ctx = SF->getASTContext();
  auto &importCache = Ctx->getImportCache();
  Ctx.evaluator.enumerateReferencesInFile(SF, [&](const auto &reference) {
    auto module = reference.subject.getModuleContext();

    // Iterate through all access paths visible (from the top level or exported elsewhere) leading to the referenced module.
    // Assume this lookup is *actually* cached and not exensive to look up for every reference in the file.
    for (auto &path : importCache.getAllVisibleAccessPaths(module, dc)) {
      
      if (path.isScoped()) {
        // check if path to module provides this specific nominal type
        // ScopedImportLookupRequest?
      } else {
        referencesByAccessPath[path].insert(reference);
      }
    }
  }

  for (auto currentImport : SF.getImports()) {
    bool importIsRedundant = false;
    auto currentAccessPath = currentImport.accessPath();
    auto currentProvidedReferences = referencesByAccessPath[currentAccessPath];
    auto scopedReferencesForImport = currentProvidedReferences...butScoped
    if (currentProvidedReferences.count == 0 {
      //diag unused
      continue;
    }

    for (auto otherImport : SF.getImports()) {
        // Don't evaluate ourselves.
        if (currentImport == otherImport) { continue };

        auto theirAccessPath = otherImport.accessPath();
        if (myAccessPath == theirAccessPath) {
          if (otherImport.isExported() && !currentImport.isExported()) {
            // other import is more relevant becuase it provides an export. Make a note.
            continue;
          }
        }

        auto theirProvidedReferences = referencesByAccessPath[theirAccessPath];
    }

  }
}
*/
