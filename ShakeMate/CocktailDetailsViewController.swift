//
//  CocktailDetailsViewController.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 10.07.2024..
//

import UIKit
import Combine

class CocktailDetailViewController: UIViewController {
    
    private var viewModel: CocktailDetailViewModel!
    private var cancellables: Set<AnyCancellable> = []
    private var detailsView: CocktailDetailsView?

    init(cocktailId: String) {
        self.viewModel = CocktailDetailViewModel(cocktailId: cocktailId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.$cocktail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cocktail in
                self?.updateUI(with: cocktail)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }

    private func updateUI(with cocktail: Cocktail?) {
        guard let cocktail = cocktail else { return }

        let ingredients = extractIngredients(from: cocktail)

        detailsView?.removeFromSuperview()
        detailsView = CocktailDetailsView(
            frame: CGRect.zero,
            backgroundImage: cocktail.strDrinkThumb,
            name: cocktail.strDrink,
            category: cocktail.strCategory,
            alcoholic: cocktail.strAlcoholic,
            glass: cocktail.strGlass,
            instructions: cocktail.strInstructions,
            ingredients: ingredients
        )
        view.addSubview(detailsView!)
        detailsView?.autoPinEdgesToSuperviewEdges()
        detailsView?.animateLabels()
    }

    private func extractIngredients(from cocktail: Cocktail) -> [(String, String)] {
        var ingredients: [(String, String)] = []

        let ingredientMeasurePairs = [
            (cocktail.strIngredient1, cocktail.strMeasure1),
            (cocktail.strIngredient2, cocktail.strMeasure2),
            (cocktail.strIngredient3, cocktail.strMeasure3),
            (cocktail.strIngredient4, cocktail.strMeasure4),
            (cocktail.strIngredient5, cocktail.strMeasure5),
            (cocktail.strIngredient6, cocktail.strMeasure6),
            (cocktail.strIngredient7, cocktail.strMeasure7),
            (cocktail.strIngredient8, cocktail.strMeasure8),
            (cocktail.strIngredient9, cocktail.strMeasure9),
            (cocktail.strIngredient10, cocktail.strMeasure10),
            (cocktail.strIngredient11, cocktail.strMeasure11),
            (cocktail.strIngredient12, cocktail.strMeasure12),
            (cocktail.strIngredient13, cocktail.strMeasure13),
            (cocktail.strIngredient14, cocktail.strMeasure14),
            (cocktail.strIngredient15, cocktail.strMeasure15)
        ]

        for (ingredient, measure) in ingredientMeasurePairs {
            if let ingredient = ingredient, !ingredient.isEmpty {
                ingredients.append((ingredient, measure ?? ""))
            }
        }

        return ingredients
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
 // MARK: - COCKTAIL DETAILS VIEW

class CocktailDetailsView: UIView {
    
    // MARK: - Properties
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    private let catAlcLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    private let glassLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines=0
        label.alpha = 0
        return label
    }()
    
    
    
    private let gridView: IngredientsGridView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let gridView = IngredientsGridView(frame: .zero, collectionViewLayout: layout)
        gridView.backgroundColor = .white
        gridView.alpha = 0
        return gridView
    }()
    
    // MARK: - Initialization
    init(frame: CGRect, backgroundImage: String?, name: String?, category: String?, alcoholic: String?, glass: String?, instructions: String?, ingredients: [(String, String)]) {
        super.init(frame: .zero)
        setupSubviews()
        
        if let backgroundImage = backgroundImage {
            backgroundImageView.kf.setImage(with: URL(string: backgroundImage), placeholder: UIImage(named: "placeholder"))
        }
        nameLabel.text = name
        
        catAlcLabel.text = alcoholic == nil ? (category ?? "Cocktail") : alcoholic! + " - " + (category ?? "Cocktail")
        glassLabel.text = glass
        instructionsLabel.text = instructions
        gridView.elements = ingredients
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let superview = superview {
            frame = superview.safeAreaLayoutGuide.layoutFrame
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        setupConstraints(with: superview)
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(backgroundImageView)
        addSubview(nameLabel)
        addSubview(catAlcLabel)
        addSubview(glassLabel)
        addSubview(instructionsLabel)
        addSubview(gridView)
    }
    
    private func setupConstraints(with superview: UIView) {
        backgroundImageView.autoPinEdge(toSuperviewEdge: .leading)
        backgroundImageView.autoPinEdge(toSuperviewEdge: .trailing)
        backgroundImageView.autoPinEdge(toSuperviewEdge: .top)
        backgroundImageView.autoMatch(.height, to: .height, of: self, withMultiplier: 0.4)
        
        nameLabel.autoPinEdge(.top, to: .bottom, of: backgroundImageView, withOffset: 20)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        catAlcLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 10)
        catAlcLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
//        categoryLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
              
        glassLabel.autoPinEdge(.top, to: .bottom, of: catAlcLabel, withOffset: 10)
        glassLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        glassLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        instructionsLabel.autoPinEdge(.top, to: .bottom, of: glassLabel, withOffset: 20)
        instructionsLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        instructionsLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        gridView.autoPinEdge(.top, to: .bottom, of: instructionsLabel, withOffset: 20)
        gridView.autoPinEdge(toSuperviewEdge: .leading)
        gridView.autoPinEdge(toSuperviewEdge: .trailing)
        gridView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    
    func animateLabels() {
            // Initial off-screen position
            nameLabel.transform = nameLabel.transform.translatedBy(x: -frame.width, y: 0)
            catAlcLabel.transform = catAlcLabel.transform.translatedBy(x: -frame.width, y: 0)
            glassLabel.transform = glassLabel.transform.translatedBy(x: -frame.width, y: 0)
            instructionsLabel.transform = instructionsLabel.transform.translatedBy(x: -frame.width, y: 0)

            // Animate labels sliding in from the left
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
                self.nameLabel.transform = .identity
                self.nameLabel.alpha = 1.0
            })
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseInOut], animations: {
                self.catAlcLabel.transform = .identity
                self.catAlcLabel.alpha = 1.0
            })
            
            UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseInOut], animations: {
                self.glassLabel.transform = .identity
                self.glassLabel.alpha = 1.0
            })
            
            UIView.animate(withDuration: 0.2, delay: 0.4, options: [.curveEaseInOut], animations: {
                self.instructionsLabel.transform = .identity
                self.instructionsLabel.alpha = 1.0
            }, completion: { _ in
                // Fade in grid view uration: 0.3, delay: 0.1) {
                self.gridView.alpha = 1.0
                })
        }
            
        
}

class IngredientsGridView: UICollectionView {
    
    // MARK: - Properties
    var elements: [(ingredient: String, measure: String)] = [] {
        didSet {
            reloadData()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        backgroundColor = .clear
        delegate = self
        dataSource = self
        register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource

extension IngredientsGridView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseIdentifier, for: indexPath) as? GridCell else {
            fatalError("Unable to dequeue GridCell")
        }
        
        let element = elements[indexPath.item]
        cell.nameLabel.text = element.ingredient
        cell.roleLabel.text = element.measure
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Grid Cell

class GridCell: UICollectionViewCell {
    
    static let reuseIdentifier = "GridCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let roleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(roleLabel)
        
        nameLabel.autoPinEdge(toSuperviewEdge: .top)
        nameLabel.autoPinEdge(toSuperviewEdge: .leading)
        nameLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        roleLabel.autoPinEdge(.top, to: .bottom, of: nameLabel, withOffset: 5)
        roleLabel.autoPinEdge(toSuperviewEdge: .leading)
        roleLabel.autoPinEdge(toSuperviewEdge: .trailing)
        roleLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
