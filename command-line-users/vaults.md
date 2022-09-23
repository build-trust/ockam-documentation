# Vaults

Various Ockam protocols, like secure channels, key lifecycle, credential exchange, device enrollment, etc. depend on a variety of standard cryptographic primitives or building blocks. Depending on the environment, these building blocks may be provided by a software implementation or a cryptographically capable hardware component.

In order to support a variety of cryptographically capable hardware we maintain loose coupling between our protocols and how a specific building block is invoked in a specific hardware. This is achieved using an abstract Vault interface.

A concrete implementation of the Vault interface is called an Ockam Vault. Over time, and with help from the Ockam open source community, we plan to add vaults for several TEEs, TPMs, HSMs, and Secure Enclaves.

As of now, we provide a software-only Vault implementation that can be used when no cryptographic hardware is available. It allows users to store and retrieve secrets that are encrypted using cryptographic protocols.
