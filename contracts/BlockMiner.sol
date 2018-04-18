contract BlockMiner {
    uint blocksMined;

    function BlockMiner(){
        blocksMined = 0;
    }

    function mine() {
       blocksMined += 1;
    }
}
