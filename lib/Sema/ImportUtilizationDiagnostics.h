//===--- ImportUtilizationDiagnostics.h - AST-Level Diagnostics --------------*- C++ -*-===//
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

#ifndef SWIFT_SEMA_IMPORT_UTILIZATION_DIAGNOSTICS_H
#define SWIFT_SEMA_IMPORT_UTILIZATION_DIAGNOSTICS_H

//#include "swift/AST/AttrKind.h"
//#include "swift/AST/Pattern.h"
//#include "swift/AST/Expr.h"
//#include "swift/AST/Identifier.h"
#include "swift/AST/SourceFile.h"
//#include "swift/Basic/LLVM.h"
//#include "swift/Basic/SourceLoc.h"
//#include "llvm/ADT/ArrayRef.h"
//#include "llvm/ADT/Optional.h"

namespace swift {
//  class AbstractFunctionDecl;
//  class ApplyExpr;
//  class CallExpr;
//  class DeclContext;
//  class Expr;
//  class InFlightDiagnostic;
//  class Stmt;
//  class TopLevelCodeDecl;
//  class ValueDecl;

void analyzeImportUtilization(SourceFile *SF);

} // namespace swift

#endif // SWIFT_SEMA_IMPORT_UTILIZATION_DIAGNOSTICS_H

