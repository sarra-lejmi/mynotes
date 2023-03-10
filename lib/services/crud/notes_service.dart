// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:mynotes/extensions/list/filter.dart';
// import 'package:mynotes/services/crud/crud_exceptions.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// const idColumn = "id";
// const emailColumn = "email";
// const userIdColumn = "user_id";
// const textColumn = "text";
// const isSyncedWithCloudColumn = "is_synced_with_cloud";
// const dbName = "notes.db";
// const noteTable = "note";
// const userTable = "user";
// const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
// 	"id"	INTEGER NOT NULL,
// 	"email"	TEXT NOT NULL UNIQUE,
// 	PRIMARY KEY("id" AUTOINCREMENT)
// ); ''';
// const createNoteTable = ''' CREATE TABLE IF NOT EXISTS "note" (
// 	"id"	INTEGER NOT NULL,
// 	"user_id"	INTEGER NOT NULL,
// 	"text"	TEXT,
// 	"is_synced_with_cloud"	INTEGER DEFAULT 0,
// 	FOREIGN KEY("user_id") REFERENCES "user"("id"),
// 	PRIMARY KEY("id" AUTOINCREMENT)
// ); ''';

// @immutable
// class UserDB {
//   final int id;
//   final String email;

//   const UserDB({required this.id, required this.email});

//   UserDB.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => "Person, ID = $id, email = $email";

//   @override
//   bool operator ==(covariant UserDB other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class NoteDB {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   NoteDB({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   NoteDB.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud";

//   @override
//   bool operator ==(covariant NoteDB other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class NotesService {
//   Database? _db;
//   List<NoteDB> _notes = [];
//   UserDB? _user;

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<NoteDB>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }

//   factory NotesService() => _shared;

//   late final StreamController<List<NoteDB>> _notesStreamController;

//   Stream<List<NoteDB>> get allNotes => _notesStreamController.stream.filter((note) {
//     final currentUser = _user;

//     if (currentUser != null) {
//       return note.userId == currentUser.id;
//     } else {
//       throw UserShouldBeSetBeforeReadingAllNotes();
//     }
//   });

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();

//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }

//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       await db.execute(createUserTable);

//       await db.execute(createNoteTable);

//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectory();
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {}
//   }

//   Future<void> close() async {
//     final db = _db;

//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     final deletedCount = await db.delete(userTable,
//         where: "email = ?", whereArgs: [email.toLowerCase()]);

//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Future<UserDB> createUser({required String email}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final results = await db.query(userTable,
//         limit: 1, where: "email = ?", whereArgs: [email.toLowerCase()]);
//     if (results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     final userId =
//         await db.insert(userTable, {emailColumn: email.toLowerCase()});

//     return UserDB(id: userId, email: email);
//   }

//   Future<UserDB> getUser({required String email}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     final results = await db.query(userTable,
//         limit: 1, where: "email = ?", whereArgs: [email.toLowerCase()]);

//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return UserDB.fromRow(results.first);
//     }
//   }

//   Future<UserDB> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);

//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);

//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<NoteDB> createNote({required UserDB owner}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final dbUser = await getUser(email: owner.email);

//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }
//     const text = "";

//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = NoteDB(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final deleteCount = await db.delete(
//       noteTable,
//       where: "id = ?",
//       whereArgs: [id],
//     );

//     if (deleteCount == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletions;
//   }

//   Future<NoteDB> getNote({required int id}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: "id = ?",
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) {
//       throw CouldNoteFindNote();
//     } else {
//       final note = NoteDB.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<Iterable<NoteDB>> getAllNotes() async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);

//     return notes.map((noteRow) => NoteDB.fromRow(noteRow));
//   }

//   Future<NoteDB> updateNote(
//       {required NoteDB note, required String text}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     await getNote(id: note.id);

//     final updatesCount = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: "id = ?",
//       whereArgs: [note.id],
//     );

//     if (updatesCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);

//       return updatedNote;
//     }
//   }
// }
