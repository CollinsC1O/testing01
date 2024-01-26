#[starknet::interface]
trait IHelloStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloStarknet {
    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[abi(embed_v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}


// unit testing

#[cfg(test)]
mod test {
    use session_test::IHelloStarknetDispatcherTrait;
    use core::result::ResultTrait;
    use starknet::ContractAddress;
    use super::IHelloStarknet;
    use super::IHelloStarknetDispatcher;
    use snforge_std::{declare, ContractClassTrait, start_prank, stop_prank};
    use super::Account::{user1}

    mod Error {
        const INVALID_AMOUNT: felt252 = 'Amount cannot be zero';
    }

    const AMOUNT_INCREASE: felt252 = 800;

    //helper function    
    fn deploy_contract() -> ContractAddress {
        let contract = declare('HelloStarknet');
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
        contract_address
    }

    #[test]
    fn test_increase_balance() {
        let contract_address = deploy_contract();
        let dispatcher = IHelloStarknetDispatcher { contract_address };
        dispatcher.increase_balance(AMOUNT_INCREASE);
        let balance = dispatcher.get_balance();
        assert(balance == AMOUNT_INCREASE, Error::INVALID_AMOUNT);
    }

    #[test]
    #[should_panic(expected: ('Amount cannot be 0',))]
    fn test_zero_param() {
        let contract_address = deploy_contract();
        let dispatcher = IHelloStarknetDispatcher { contract_address };
        dispatcher.increase_balance(0);
    }
}

mod Account {
    use core::option::OptionTrait;
    use traits::tryInto;
    use starkmet::ContractAddress;
    fn user1() -> ContractAddress{
        'user'.try_into().unwrap()
    }
}