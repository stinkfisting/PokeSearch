//
//  PokeCell.swift
//  PokeSearch
//
//  Created by Marcus Tam on 2/28/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var pokeImage: UIImageView!
    @IBOutlet weak var pokeImgLbl: UILabel!
    
    
    func configureCell(poke: String){
        var indexNumber: Int
        
        pokeImgLbl.text = poke
        //index of poke in pokemon Array
        indexNumber = pokemon.index(of: poke)!
        pokeImage.image = UIImage(named: "\(indexNumber + 1)")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
        
    }
}
