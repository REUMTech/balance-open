//
//  InstitutionTableHeaderView.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

fileprivate extension Source {
    var accountsLogo: UIImage? {
        switch self {
        case .coinbase: return #imageLiteral(resourceName: "coinbaseAccounts")
        case .poloniex: return #imageLiteral(resourceName: "poloniexAccounts")
        case .gdax:     return #imageLiteral(resourceName: "gdaxAccounts")
        case .bitfinex: return #imageLiteral(resourceName: "bitfinexAccounts")
        case .kraken:   return #imageLiteral(resourceName: "krakenAccounts")
        case .bittrex:  return #imageLiteral(resourceName: "bittrexAccounts")
        default:        return nil
        }
    }
}

final class InstitutionTableHeaderView: UITableViewHeaderFooterView, Reusable {
    // Internal
    var institution: Institution? {
        didSet {
            self.reloadData()
        }
    }

    // Private
    private let logoView = UIImageView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.accounts.headerCell.nameFont
        label.textColor = CurrentTheme.accounts.headerCell.nameColor
        
        return label
    }()
    
    private let totalBalanceLabel: UILabel = {
        let label = UILabel()
        label.font = CurrentTheme.accounts.headerCell.totalBalanceFont
        label.textColor = CurrentTheme.accounts.headerCell.totalBalanceColor
        
        return label
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = CurrentTheme.accounts.headerCell.bottomBorderColor
        
        return view
    }()
    
    // MARK: Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Name label
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(15.0)
            make.centerY.equalToSuperview()
        }
        
        // Total balance label
        self.contentView.addSubview(self.totalBalanceLabel)
        self.totalBalanceLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15.0)
            make.centerY.equalToSuperview()
        }
        
        // Logo view
        self.logoView.backgroundColor = UIColor.clear
        self.logoView.isHidden = true
        self.contentView.addSubview(self.logoView)
        self.logoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(0)
            make.height.equalTo(0)
            make.centerY.equalToSuperview()
        }
        
        // Bottom border
        self.contentView.addSubview(self.bottomBorder)
        self.bottomBorder.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: Data
    
    private func reloadData() {
        guard let unwrappedInstitution = self.institution else {
            return
        }
        
        self.nameLabel.text = unwrappedInstitution.displayName
        self.totalBalanceLabel.text = "TODO: $1,000,000"

        if let logo = unwrappedInstitution.source.accountsLogo {
            logoView.image = logo
            logoView.snp.updateConstraints { make in
                make.width.equalTo(logo.size.width)
                make.height.equalTo(logo.size.height)
            }
            
            self.nameLabel.isHidden = true
            self.logoView.isHidden = false
        } else {
            self.nameLabel.isHidden = false
            self.logoView.isHidden = true
        }
        
        // Total balance
        let accounts = AccountRepository.si.accounts(institutionId: unwrappedInstitution.institutionId, includeHidden: false)
        let totalAmount = accounts.reduce(0) { (total, account) -> Int in
            return total + (account.displayAltBalance ?? 0)
        }
        
        self.totalBalanceLabel.text = amountToString(amount: totalAmount, currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: true)
    }
}