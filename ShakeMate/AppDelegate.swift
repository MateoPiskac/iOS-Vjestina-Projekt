//
//  AppDelegate.swift
//  ShakeMate
//
//  Created by Mateo Piskac on 10.07.2024..
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
        window = UIWindow(frame: UIScreen.main.bounds)

                let cocktailViewModel = CocktailViewModel()
                let favoriteCocktailViewModel = FavoriteCocktailViewModel()

                let cocktailListVC = CocktailListViewController(viewModel: cocktailViewModel)
                let favoriteCocktailVC = FavoriteCocktailViewController(viewModel: favoriteCocktailViewModel)

                let tabBarController = UITabBarController()
                tabBarController.viewControllers = [
                    UINavigationController(rootViewController: cocktailListVC),
                    UINavigationController(rootViewController: favoriteCocktailVC)
                ]

                cocktailListVC.tabBarItem = UITabBarItem(title: "Cocktails", image: UIImage(systemName: "list.bullet"), tag: 0)
                favoriteCocktailVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star.fill"), tag: 1)

                window?.rootViewController = tabBarController
                window?.makeKeyAndVisible()

                return true
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}


