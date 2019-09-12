abstract class MessengerException implements Exception{
    String errorMessage();
}
class UserNotFoundException extends MessengerException{
  @override
  String errorMessage() => 'No user found for provided uid/username';

}
class UsernameMappingUndefinedException extends MessengerException{
  @override
  String errorMessage() =>'User not found';

}
class ContactAlreadyExistsException extends MessengerException{
  @override
  String errorMessage() => 'Contact already exists!';
}