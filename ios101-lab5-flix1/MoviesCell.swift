//
//  MoviesCell.swift
//  ios101-lab5-flix1
//
//  Created by Michael on 26/06/2024.
//

import UIKit

class MoviesCell: UITableViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
