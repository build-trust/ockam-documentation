# End-to-End Data Integrity and Authenticity

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Application layer communication is also usually bi-directional since, at the very least, we have to acknowledge receipt of data to its senders. This means that authentication and the data integrity guarantee within applications must be **mutual** between any two communicating parts.

With Ockam, applications can, in a few lines of code, create mutually authenticated secure channels that guarantee end-to-end data integrity to senders and receivers of data.
