//
//  TaxUseCase.swift
//  RxSwift-Tax-Practice
//
//  Created by 大西玲音 on 2021/08/03.
//

import RxSwift
import RxRelay

final class TaxUseCase {
    
    private let repository: TaxRepositoryProtocol
    init(repository: TaxRepositoryProtocol) {
        self.repository = repository
        setupBindings()
    }
    
    private let saveConsumptionTaxTrigger = PublishRelay<Int>()
    private let loadConsumptionTaxTrigger = PublishRelay<Void>()
    
    var consumptionTax: Observable<Int?> {
        consumptionTaxRelay.asObservable()
    }
    private let consumptionTaxRelay = BehaviorRelay<Int?>(value: nil)
    var includingTax: Observable<Int?> {
        includingTaxRelay.asObservable()
    }
    private let includingTaxRelay = BehaviorRelay<Int?>(value: nil)
    private let disposeBag = DisposeBag()
    
    private func setupBindings() {
        // 消費税保存要求が来たらリポジトリで保存する
        saveConsumptionTaxTrigger
            .flatMapLatest(repository.save(consumptionTax:))
            .subscribe()
            .disposed(by: disposeBag)
        
        // 消費税読み込み要求が来たらリポジトリから読み込んで結果をストリームに流す
        loadConsumptionTaxTrigger
            .flatMapLatest(repository.loadConsumptionTax)
            .bind(to: consumptionTaxRelay)
            .disposed(by: disposeBag)
    }
    
    func saveTax(consumptionTax: Int) {
        saveConsumptionTaxTrigger.accept(consumptionTax)
    }
    
    func loadConsumptionTax() {
        loadConsumptionTaxTrigger.accept(())
    }
    
    func calculateIncludingTax(excludingTax: Int, consumptionTax: Int) {
        let includingTax = excludingTax * (100 + consumptionTax) / 100
        includingTaxRelay.accept(includingTax)
    }
    
}
