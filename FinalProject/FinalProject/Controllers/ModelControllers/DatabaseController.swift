//
//  DatabaseController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation
import FirebaseDatabase

final class DatabaseController {
    
    // MARK: - Properties
    static let shared = DatabaseController()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    // MARK: - CRUD Functions
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = DatabaseController.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
   
    
    //MARK: -UPDATE THIS FUNCTION
    public func getAllUsers(completion: @escaping(Result<[[String : String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String : String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
}

// MARK: - Extensions

extension DatabaseController {
    
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error >) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Sending Messages / Conversations
extension DatabaseController {
    
    /// Creates a new conversation with the target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, otherUserName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                return
        }
        let safeEmail = DatabaseController.safeEmail(emailAddress: currentEmail)
        
        let ref = database.child("\(safeEmail)")
        
            ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard var userNode = snapshot.value as? [String: Any] else {
                    completion(false)
                    print("user not found")
                    return
                }
                
                let messageDate = firstMessage.sentDate
                let dateString = ChatViewController.dateFormatter.string(from: messageDate)
                
                var message = ""
                
                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
                    break
                case .emoji(_):
                    break
                case .audio(_):
                    break
                case .contact(_):
                    break
                case .linkPreview(_):
                    break
                case .custom(_):
                    break
                }
                
                let conversationID = "conversation_\(firstMessage.messageId)"
                
                let newConversationData: [String: Any] = [
                    "id" : conversationID,
                    "other_user_email": otherUserEmail,
                    "name": otherUserName,
                    "latest_message" : [
                        "date": dateString,
                        "message" : message,
                        "is_read" : false
                    ]
                ]
                
                let recipient_newConversationData: [String: Any] = [
                    "id" : conversationID,
                    "other_user_email": safeEmail,
                    "name": currentName,
                    "latest_message" : [
                        "date": dateString,
                        "message" : message,
                        "is_read" : false
                    ]
                ]
                
                // Update recipient conversation entry
                self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                    if var conversations = snapshot.value as? [[String : Any]] {
                        //append
                        conversations.append(recipient_newConversationData)
                        self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                    } else {
                        // create
                        self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                    }
                }
                
                // Update current user conversation entry
                if var conversations = userNode["conversations"] as? [[String : Any]] {
                    //conversation array exists for current user
                    // you should append
                    conversations.append(newConversationData)
                    userNode["conversations"] = conversations
                    ref.setValue(userNode, withCompletionBlock:  { [weak self] (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self?.finishCreatingConversation(name: otherUserName, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    })
                } else {
                    // conversation array does not exist
                    // create it
                    userNode["conversations"] = [
                        newConversationData
                    ]
                    
                    ref.setValue(userNode) { [weak self] (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self?.finishCreatingConversation(name: otherUserName, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                        
                }
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        "id": String,
//        "type": text, photo, video,
//        "content": String,
//        "date": Date(),
//        "sender_email": String,
//        "isRead": true/false,
//
  
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
            
        }
        
        let currentUserEmail = DatabaseController.safeEmail(emailAddress: userEmail)
        
        let collectionMessage: [String : Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
            collectionMessage
            ]
        ]
        
        
        database.child("conversations/\(conversationID)").setValue(value, withCompletionBlock: { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Fetches and returns all conversations for the user with passed email.
    public func getAllConversations(for email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { (dictionary) in
                guard let conversationID = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String : Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                        
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationID, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
                
            }
            completion(.success(conversations))
        }
    }
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        database.child("conversations/\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap { (dictionary) in
                guard let content = dictionary["content"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let messageID = dictionary["id"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let name = dictionary["name"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let type = dictionary["type"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                    
                }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                    return Message(sender: sender,
                                   messageId: messageID,
                                   sentDate: date,
                                   kind: .text(content))
                }
            completion(.success(messages))
        }
        
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserEmail: String, newMessage: Message, name: String, completion: @escaping(Bool) -> Void) {
        // add new message to messages array.
        
        // update sender latest message
        // update recipient latest message
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseController.safeEmail(emailAddress: userEmail)
        
        database.child("conversations/\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
            completion(false)
            return
        }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseController.safeEmail(emailAddress: userEmail)
            
            let newMessageEntry: [String : Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("conversations/\(conversation)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                    var databaseEntryConversations =  [[String : Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String : Any]?
                        var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentConversationID = conversationDictionary["id"] as? String, currentConversationID == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        } else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseController.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    } else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseController.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                        newConversationData
                        ]
                    }
                    
                    strongSelf.database.child("\(currentUserEmail)/conversations").setValue(databaseEntryConversations) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        // Update latest message for recipeient user.
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations =  [[String : Any]]()
                            
                            guard let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else { return }
                            
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String : Any]?
                                var position = 0
                                
                                for conversationDictionary in otherUserConversations {
                                    if let currentConversationID = conversationDictionary["id"] as? String, currentConversationID == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                } else {
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseController.safeEmail(emailAddress: currentUserEmail),
                                        "name": currentUserName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            } else {
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseController.safeEmail(emailAddress: currentUserEmail),
                                    "name": currentUserName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                            
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations) { (error, _) in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func deleteConversation(conversationID: String, completion: @escaping(Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseController.safeEmail(emailAddress: email)
        
        print("Deleting conversation with id: \(conversationID)")
        //Get all conversations for current user
        //delete conversation in collection with target id
        //reset those conversations for the user in database
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String, id == conversationID {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("failed to write new conversation array")
                        completion(false)
                        return
                    }
                    print("deleted conversation")
                    completion(true)
                })
                
            }
        }
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping(Result<String,Error>) ->Void) {
        let safeRecipientEmail = DatabaseController.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseController.safeEmail(emailAddress: senderEmail)
        
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
            guard let collection = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                    
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                //get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
            }
            completion(.failure(DatabaseError.failedToFetch))
            return
        }
       // DatabaseController
    }
}
