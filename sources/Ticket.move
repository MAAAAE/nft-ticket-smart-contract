module ticket::EventTicket {
    use std::signer;
    use std::vector;
    use aptos_framework::aptos_coin::{AptosCoin};
    use aptos_framework::coin;

    struct Ticket has key, store {
        id: u64,
        event_id: u64,
        owner: address,
        is_used: bool,
        can_transfer: bool,
        price: u64,
    }

    struct TicketStore has key, store {
        tickets: vector<Ticket>,
        ticket_count: u64,
    }

    struct ContractOwner has key {
        owner: address,
    }

    public entry fun initialize_contract_owner(owner: &signer) {
        assert!(!exists<ContractOwner>(@ticket), 1001);
        assert!(@ticket == signer::address_of(owner), 1002);
        move_to(owner, ContractOwner { owner: signer::address_of(owner) });
    }

    public entry fun initialize_ticket_store(account: &signer) {
        move_to(account, TicketStore { tickets: vector::empty<Ticket>(), ticket_count: 0 });
    }

    public entry fun create_ticket(account: &signer, event_id: u64, amount: u64) acquires TicketStore, ContractOwner {
        let account_address = signer::address_of(account);

        if (!exists<TicketStore>(account_address)) {
            move_to(account, TicketStore { tickets: vector::empty<Ticket>(), ticket_count: 0 });
        };

        let contract_owner = borrow_global<ContractOwner>(@ticket);

        let octas_amount = amount * 100_000_000;
        coin::transfer<AptosCoin>(account, contract_owner.owner, octas_amount);

        let ticket_store = borrow_global_mut<TicketStore>(account_address);
        let ticket_id = ticket_store.ticket_count;

        let ticket = Ticket {
            id: ticket_id,
            event_id,
            owner: account_address,
            is_used: false,
            can_transfer: true,
            price: amount
        };

        vector::push_back(&mut ticket_store.tickets, ticket);
        ticket_store.ticket_count = ticket_store.ticket_count + 1;
    }

    public entry fun transfer_ticket(account: &signer, recipient: address, ticket_id: u64) acquires TicketStore {
        let account_address = signer::address_of(account);

        if (!exists<TicketStore>(account_address)) {
            move_to(account, TicketStore { tickets: vector::empty<Ticket>(), ticket_count: 0 });
        };

        let target_ticket_store = borrow_global_mut<TicketStore>(account_address);
        let ticket = vector::remove(&mut target_ticket_store.tickets, ticket_id);

        assert!(ticket.owner == account_address, 102);
        assert!(ticket.can_transfer, 103);
        assert!(!ticket.is_used, 104);

        assert!(exists<TicketStore>(recipient), 105);

        let octas_amount = ticket.price * 100_000_000;
        aptos_framework::coin::transfer<AptosCoin>(account, recipient, octas_amount);

        target_ticket_store.ticket_count = target_ticket_store.ticket_count - 1;

        ticket.owner = recipient;
        ticket.can_transfer = false;

        let recipient_ticket_store = borrow_global_mut<TicketStore>(recipient);
        vector::push_back(&mut recipient_ticket_store.tickets, ticket);

        recipient_ticket_store.ticket_count  = recipient_ticket_store.ticket_count + 1;
    }
}
