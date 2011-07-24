//===--- Lexer.h - Swift Language Lexer -------------------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
//  This file defines the Lexer interface.
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_LEXER_H
#define SWIFT_LEXER_H

#include "swift/Parse/Token.h"

namespace llvm {
  class MemoryBuffer;
  class SourceMgr;
}

namespace swift {
  class Token;
  class ASTContext;

class Lexer {
  llvm::SourceMgr &SourceMgr;
  const llvm::MemoryBuffer *Buffer;
  const char *CurPtr;
  ASTContext &Context;

  Lexer(const Lexer&) = delete;
  void operator=(const Lexer&) = delete;
public:
  Lexer(unsigned BufferID, ASTContext &Context);
  
  void Lex(Token &Result);

  /// Return true if the character right before the specified location is part
  /// of an identifier.
  bool isPrecededByIdentifier(SMLoc L) const;
  
private:
  void warning(const char *Loc, const Twine &Message);
  void error(const char *Loc, const Twine &Message);
  void FormToken(tok Kind, const char *TokStart, Token &Result);
  
  void SkipSlashSlashComment();
  void LexIdentifier(Token &Result);
  void LexDollarIdent(Token &Result);
  void LexPunctuationIdentifier(Token &Result);
  void LexDigit(Token &Result);
};
  
  
} // end namespace swift

#endif
