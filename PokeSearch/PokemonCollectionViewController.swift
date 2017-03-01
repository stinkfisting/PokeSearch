//
//  PokemonCollectionViewController.swift
//  PokeSearch
//
//  Created by Marcus Tam on 2/28/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import MapKit
import GeoFire
import FirebaseDatabase

//Created this protocol to pass the selctedPokeId back to the first controller

protocol MyProtocol {
    func setResultOfPokeSelection(valueSent: Int)
}

class PokemonCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collection: UICollectionView!
    
    var inSearchMode = false
    var filteredPokemon = [String]()
    var delegate: MyProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredPokemon.count
        }
        return pokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let poke: String!
            
            if inSearchMode {
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(poke: poke)
            } else {
                poke = pokemon[indexPath.row]
                cell.configureCell(poke: poke)
            }
            return cell
            
        } else {
            
            return UICollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var selectedPoke: String!
        var selectedPokeId : Int
        
        if inSearchMode {
            selectedPoke = filteredPokemon[indexPath.row]
            selectedPokeId = pokemon.index(of: selectedPoke)! + 1
        } else {
            selectedPoke = pokemon[indexPath.row]
            selectedPokeId = indexPath.row + 1
        }
        
        print(selectedPoke)
        print(selectedPokeId)
        
        delegate?.setResultOfPokeSelection(valueSent: selectedPokeId)
        dismiss(animated: true, completion: nil)
        
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            collection.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            let lower = searchBar.text?.lowercased()
            
            //using filter like this because we have an array of string and not objects (difference from pokedex app)
            filteredPokemon = pokemon.filter{$0.range(of:lower!, options: .caseInsensitive) !=  nil}
            
            collection.reloadData()
            
            
        }
    }
}



