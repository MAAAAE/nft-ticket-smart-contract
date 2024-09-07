module ticket::EventTicket {
    use std::signer;
    use std::vector;

    struct Ticket has key, store {
        id: u64,
        event_id: u64,
        owner: address,
        is_used: bool,
        can_transfer: bool,
    }

    struct TicketStore has key, store {
        tickets: vector<Ticket>,
        ticket_count: u64,
    }

    public entry fun initialize_ticket_store(account: &signer) {
        move_to(account, TicketStore { tickets: vector::empty<Ticket>(), ticket_count: 0 });
    }

    public entry fun create_ticket(account: &signer, event_id: u64) acquires TicketStore {
        let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
        let ticket_id = ticket_store.ticket_count;

        let ticket = Ticket {
            id: ticket_id,
            event_id: event_id,
            owner: signer::address_of(account),
            is_used: false,
            can_transfer: true,
        };

        vector::push_back(&mut ticket_store.tickets, ticket);
        ticket_store.ticket_count = ticket_store.ticket_count + 1;
    }

    public entry fun transfer_ticket(account: &signer, recipient: address, ticket_id: u64) acquires TicketStore {
        let target_ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
        let ticket = vector::remove(&mut target_ticket_store.tickets, ticket_id);
        
        assert!(ticket.owner == signer::address_of(account), 102);
        assert!(ticket.can_transfer, 103);
        assert!(!ticket.is_used, 104);

        target_ticket_store.ticket_count = target_ticket_store.ticket_count - 1;

        ticket.owner = recipient;
        ticket.can_transfer = false;

        let recipient_ticket_store = borrow_global_mut<TicketStore>(recipient);
        vector::push_back(&mut recipient_ticket_store.tickets, ticket);

        recipient_ticket_store.ticket_count  = recipient_ticket_store.ticket_count + 1;
    }

    // public entry fun use_ticket(account: &signer, ticket_id: u64) acquires TicketStore {
    //     let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
    //     let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
    //     assert!(ticket.owner == signer::address_of(account), 101);
    //     assert!(!ticket.is_used, 103);

    //     ticket.is_used = true;
    // }
}
