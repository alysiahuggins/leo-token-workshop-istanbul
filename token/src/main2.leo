program token2.aleo{
    mapping account: address => u64; 

    record token {
        owner: address;
        amount: u64;
    }

    transition mint_public(public receiver:address, public amount:u64){
        return then finalize(receiver, amount);
    }

    finalize mint_public(public receiver: address, public amount: u64){
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition mint_private(receiver:address, amount:u64) -> token2{
        return token2 {
            owner:receiver,
            amount:amount
        };
    }

    transition transfer_public(public receiver:address, public amount:u64){
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender:address, public receiver:address, public amount:u64){
        //decrease the amount of sender and increase the amount of receiver
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping:set(account, sender, sender_amount - amount);

        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping:set(account, receiver, receiver_amount + amount);
    }

    //to keep transactions
    transition transfer_private(sender: token2, receiver:address, amount:u64){
        let difference: u64 = sender.amount - amount;
        let remaining: token2 = token2 {
            owner: sender.owner,
            amount:  difference
        };

        let transferred: token2 = token2{
            owner: receiver,
            amount: amount
        };

        return (remaining, transferred);
    }

    transition private_to_public(public receiver;address, public amount:u64){
        let receiver_amount:u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount+amount);
    }

    transition public_to_private(public receiver: address, public amount:u64) => token2
