module ticket::EventTicket {
    use std::signer;
    use std::string;
    use std::vector;

    struct Ticket has key, store {
        id: u64,
        event_name: string::String,
        owner: address,
        is_used: bool,
        price: u64,
        can_transfer: bool,
    }

    struct TicketStore has key, store {
        tickets: vector<Ticket>,
        ticket_count: u64,
    }

    public fun initialize_ticket_store(account: &signer) {
        move_to(account, TicketStore { tickets: vector::empty<Ticket>(), ticket_count: 0 });
    }

    public fun create_ticket(account: &signer, event_name: string::String, price: u64) acquires TicketStore {
        let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
        let ticket_id = ticket_store.ticket_count;
        let ticket = Ticket {
            id: ticket_id,
            event_name: event_name,
            owner: signer::address_of(account),
            is_used: false,
            price: price,
            can_transfer: false,
        };
        vector::push_back(&mut ticket_store.tickets, ticket);
        ticket_store.ticket_count = ticket_store.ticket_count + 1;
    }

    public fun allow_transfer(account: &signer, ticket_id: u64) acquires TicketStore {
        let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
        let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
        assert!(ticket.owner == signer::address_of(account), 100);
        ticket.can_transfer = true;
    }

    public fun transfer_ticket(account: &signer, recipient: address, ticket_id: u64, sale_price: u64) acquires TicketStore {
        let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
        let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
        assert!(ticket.owner == signer::address_of(account), 100);
        assert!(!ticket.is_used, 101);
        assert!(ticket.can_transfer, 102);
        assert!(sale_price <= ticket.price, 103);
        ticket.owner = recipient;
        ticket.can_transfer = false;
    }

    public fun use_ticket(account: &signer, ticket_id: u64) acquires TicketStore {
        let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
        let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
        assert!(ticket.owner == signer::address_of(account), 100);
        assert!(!ticket.is_used, 101);
        ticket.is_used = true;
    }

    public fun get_ticket_details(account: address, ticket_id: u64): (string::String, address, bool, u64, bool) acquires TicketStore {
        let ticket_store = borrow_global<TicketStore>(account);
        let ticket = vector::borrow(&ticket_store.tickets, ticket_id);
        (ticket.event_name, ticket.owner, ticket.is_used, ticket.price, ticket.can_transfer)
    }
}
