# Zero KNowldege Proof Workshop
The public repo for the Zero knowledge workshop for RTC 23

## Install Zokrates with Docker

Start this as soon as possible - this might take a couple minutes:

1. Install Docker   
* For mac: https://docs.docker.com/docker-for-mac/install/
* For windows: https://docs.docker.com/docker-for-windows/install/ 
* For linux: https://docs.docker.com/install/linux/docker-ce/ubuntu/ 

2. Run a docker container to get Zokrates v0.3.0     
First we'll create a working directory. Create an empty folder somewhere on your machine. 
```
cd <working directory>
mkdir <folder>
```
Next, we'll run a docker container with the Zokrates v0.3.0 image, and give it a volume which is that folder you created so files can sync from your host machine to to the `/home/zokrates/code` directory in your docker container. This might take a few minutes as it needs a lot to download to create your container.  
```
docker run -v <path for your folder>:/home/zokrates/code -ti zokrates/zokrates:0.3.0 /bin/bash 
```

EXAMPLE: `docker run -v ~/Documents/Code/rtc:/home/zokrates/code -ti zokrates/zokrates:0.3.0 /bin/bash`


## Intro to Zokrates: What is it

[Zokrates](https://github.com/Zokrates/ZoKrates) is an amazing project that provides a DSL (Domain Specific Language) which is a custom higher level language that translates your code into a zk-SNARK. It is a "tool box for zk-SNARKs on Ethereum" and will allow us to write functions such that the output can be verified on-chain. Zokrates has a dependency on libsnark, which is a C++ library released by the authors of zk-SNARKs and requires a lot of dependencies that are os-specific, hence why it's built inside a docker container.

The Zokrates DSL is fairly intuitive, and we'll walk through some examples to get a sense of the syntax. 


## First Puzzle

### Create the puzzle

The first puzzle we'll create with Zokrates is: <b>What x and y add up to x * y + 4 == 10 ? </b>

(This is the exact example from the slides)

1. Open up the folder you created in your favorite editor, and make a new file `addToTen.code` 

    This program will verify inputs to determine whether or not they really do add up to 10. This program will be translated into an arithmetic circuit with constrains to generate a proof. This verifier program is public and necessary for someone to generate a proof, so you cannot give away the answer to the question in the verification process. 

    This is the code: 

    ```
    def main(private field x, private field y) -> (field):
        x * y + 4 == 10
        return 1
    ```

2. Now we'll have to compile our program. Go back to your docker container, and navigate to the folder we synced. We'll then use the zokrates CLI to compile:

    ```
    cd code
    ~/zokrates compile -i addToTen.code
    ```

    You should see your code being "flattened" like we went over in our example from the slides 

3. Now that we have our circuit, we need our "trusted setup" 
    ```
    ~/zokrates setup
    ```

    Note - you will need a new setup for every new circuit you make. So if you change your code, you'll have to run this command again. 

4. Next, we need to compute our "witness" that knows the answer to the puzzle 

    ```
    ~/zokrates compute-witness -a 2 3
    ```

    Notice there's a 'witness' file created now that has the steps of the computation. 

5. Now we're ready to generate our proof based on our witness. 

    ```
    ~/zokrates generate-proof
    ```

    Notice that this gives you evaluations of your polynomials such that A * B - C = H * K evaluated on some encrypted point, (with some other values corresponding to the blinding factors of A, B, and C). 

6. We're ready to generate our Verifier smart contract! 
    ```
    ~/zokrates export-verifier
    ```

    Notice that this generated a verifier.sol contract. Let's go ahead and rename it to something we can identify later, like TenVerifier.sol (you'll have to change the contract name also on line 144)
