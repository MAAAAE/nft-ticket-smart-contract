module ticket::EventTicket {
    use std::signer;
    use std::string;
    use std::vector;

    struct Event has key, store {
        id: u64,
        name: string::String,
        date: u64,
        ticket_price: u64,
        available_tickets: u64,
    }

    struct Ticket has key, store {
        id: u64,
        event_id: u64,
        owner: address,
        is_used: bool,
        can_transfer: bool,
    }

    struct EventStore has key, store {
        events: vector<Event>,
        event_count: u64,
    }

    struct TicketStore has key, store {
        tickets: vector<Ticket>,
        ticket_count: u64,
    }

    public entry fun initialize_event_store(account: &signer) {
        move_to(account, EventStore { events: vector::empty<Event>(), event_count: 0 });
    }

    public entry fun initialize_ticket_store(account: &signer) {
        move_to(account, TicketStore { tickets: vector::empty<Ticket>(), ticket_count: 0 });
    }

    public entry fun create_event(account: &signer, name: string::String, date: u64, price: u64, available_tickets: u64) acquires EventStore {
        let event_store = borrow_global_mut<EventStore>(signer::address_of(account));
        let event_id = event_store.event_count;
        let event = Event {
            id: event_id,
            name: name,
            date: date,
            ticket_price: price,
            available_tickets: available_tickets,
        };
        vector::push_back(&mut event_store.events, event);
        event_store.event_count = event_store.event_count + 1;
    }

    public entry fun create_ticket(account: &signer, event_id: u64, owner_address: address) acquires EventStore, TicketStore {
        let event_store = borrow_global_mut<EventStore>(signer::address_of(account));
        let event = vector::borrow_mut(&mut event_store.events, event_id);

        let ticket_store = borrow_global_mut<TicketStore>(owner_address);
        let ticket_id = ticket_store.ticket_count;
        assert!(event.available_tickets > 0, 100);

        let ticket = Ticket {
            id: ticket_id,
            event_id: event_id,
            owner: owner_address,
            is_used: false,
            can_transfer: false,
        };

        vector::push_back(&mut ticket_store.tickets, ticket);
        ticket_store.ticket_count = ticket_store.ticket_count + 1;

        event.available_tickets = event.available_tickets - 1;
    }


    // public fun allow_transfer(account: &signer, ticket_id: u64) acquires TicketStore {
    //     let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
    //     let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
    //     assert!(ticket.owner == signer::address_of(account), 101);
    //     ticket.can_transfer = true;
    // }

    // public fun transfer_ticket(account: &signer, recipient: address, ticket_id: u64) acquires TicketStore {
    //     let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
    //     let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
    //     assert!(ticket.owner == signer::address_of(account), 101);
    //     assert!(ticket.can_transfer, 102);
    //     assert!(!ticket.is_used, 103);

    //     ticket.owner = recipient;
    //     ticket.can_transfer = false;
    // }

    // public fun use_ticket(account: &signer, ticket_id: u64) acquires TicketStore {
    //     let ticket_store = borrow_global_mut<TicketStore>(signer::address_of(account));
    //     let ticket = vector::borrow_mut(&mut ticket_store.tickets, ticket_id);
    //     assert!(ticket.owner == signer::address_of(account), 101);
    //     assert!(!ticket.is_used, 103);

    //     ticket.is_used = true;
    // }
}
