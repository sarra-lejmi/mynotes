class CloudStrorageException implements Exception {
  const CloudStrorageException();
}

class CouldNotCreateNoteExcception extends CloudStrorageException {}

class CouldNotGetAllNotesException extends CloudStrorageException {}

class CouldNotUpdateNoteException extends CloudStrorageException {}

class CouldNotDeleteNoteException extends CloudStrorageException {}