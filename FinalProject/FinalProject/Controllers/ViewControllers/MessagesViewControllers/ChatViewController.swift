//
//  ChatViewController.swift
//  FinalProject
//
//  Created by Owen Barrott on 11/23/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserUid: String
    public let otherUserName: String?
    var otherUser: User?
    private var conversationID: String?
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let userUid = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey)  as? String else { return nil }
        //let safeEmail = MessageController.safeEmail(emailAddress: email)
        
        return Sender(photoURL: "",
                      senderId: userUid,
                      displayName: "Me")
    }
    
    
    
    init(with otherUserUid: String, otherUserName: String?, id: String?) {
        self.otherUserUid = otherUserUid
        self.otherUserName = otherUserName
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        MessageController.shared.getAllMessagesForConversation(with: id) { [weak self] (result) in
            switch result {
            case .success(let messages):
                print("success in getting messages")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }
    // MARK: - Actions
    @objc private func meetupSpotsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RestaurantTableViewController")
        vc.title = "Restauraunts"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func titleButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var story = storyboard.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        story.otherUser = otherUser
        //vc.updateViews()
        self.present(story, animated: true, completion: nil)
    
    }
    
    
    // MARK: - Views
    func setupViews(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Meetup Spots",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(meetupSpotsTapped))
        createTitleButton()
      
    }
    
    private func createTitleButton() {
        let titleButton = UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor = .none
        titleButton.setTitle(otherUserName, for: .normal)
        titleButton.setTitleColor(.link, for: .normal)
        titleButton.addTarget(self, action: #selector(titleButtonTapped), for:. touchUpInside)
        navigationItem.titleView = titleButton
    }
    
    
   
    
}// End of Class

// MARK: - Extensions

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageID = createMessageID() else {
            return
        }
        
        print("Sending: \(text)")
        
        let message = Message(sender: selfSender,
                              messageId: messageID,
                              sentDate: Date(),
                              kind: .text(text))
        // Send Message
        if isNewConversation {
            // create conversation in Database
            MessageController.shared.createNewConversation(with: otherUserUid, otherUserName: self.title ?? "User", firstMessage: message) { [weak self] (success) in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationID = "conversation_\(message.messageId)"
                    self?.conversationID = newConversationID
                    self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("failed to send")
                }
            }
        } else {
            guard let conversationID = conversationID, let name = self.title else { return }
            // append to existing conversation data
            MessageController.shared.sendMessage(to: conversationID, otherUserUid: otherUserUid, newMessage: message, name: name) { (success) in
                if success {
                    print("message sent")
                } else {
                    print("failed to send")
                }
            }
        }
        inputBar.inputTextView.text = ""
    }
    
    private func createMessageID() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        
        guard let currentUserUid = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) as? String else { return nil }
        
        //let safeCurrentEmail = MessageController.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = ChatViewController.self.dateFormatter.string(from: Date())
        
        let newIdentifier = "\(otherUserUid)_\(currentUserUid)_\(dateString)"
        
        print("Created message id: \(newIdentifier)")
        
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}




