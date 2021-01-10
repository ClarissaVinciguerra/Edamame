//
//  FriendTableViewCell.swift
//  FinalProject
//
//  Created by Owen Barrott on 1/7/21.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
    // MARK: - Properties
    var conversation: Conversation?
    var friend: User?
    
    var photo: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Helper Functions
    func updateViews() {
        if let conversation = conversation {
            nameLabel.text = conversation.name
            latestMessageLabel.text = conversation.latestMessage.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy 'at' hh:mm:ss a z"
            let dateObj = dateFormatter.date(from: conversation.latestMessage.date)
            let dateString = dateObj?.formatRelativeString()
            timeLabel.text = dateString
        }
        
        if let photo = photo {
            friendImageView.image = photo
        } else {
            imageView?.image = nil
        }
        
        friendImageView.layer.masksToBounds = true
        friendImageView.contentMode = .scaleAspectFill
        friendImageView.layer.cornerRadius = 50
    }
}

extension Date {
    
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true
        
        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self){
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday-1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }
        
        return dateFormatter.string(from: self)
    }
}
