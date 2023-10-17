---
description: >-
  Ockam Vaults store secret cryptographic keys in hardware and cloud key
  management systems. These keys remain behind a stricter security boundary and
  can be used without being revealed.
---

# Keys and Vaults

Ockam Identities, Credentials, and Secure Channels rely on cryptographic proofs of possession of specific secret keys. Ockam Vaults safely store these secret keys in cryptographic hardware and cloud key management systems.

## Serialization

{% code lineNumbers="true" fullWidth="true" %}
```rust
// The types below that are annotated with #[derive(Encode, Decode)] are
// serialized using [CBOR](1). The various annotations and their effects on the
// encoding are defined in the [minicbor_derive](3) crate.
//
// #[derive(Encode, Decode)] on structs and enums implies #[cbor(array)]
// and CBOR [array encoding](4). The #[n(..)] annotation specifies the index
// position of the field in the CBOR encoded array.
//
// #[cbor(transparent)] annotation on structs with exactly one field forwards
// the respective encode and decode calls to the inner type, i.e. the resulting
// CBOR representation will be identical to the one of the inner type.
//
// [1]: https://www.rfc-editor.org/rfc/rfc8949.html
// [2]: https://docs.rs/minicbor/latest/minicbor
// [3]: https://docs.rs/minicbor-derive/latest/minicbor_derive/index.html
// [4]: https://docs.rs/minicbor-derive/latest/minicbor_derive/index.html#array-encoding
use minicbor::{Decode, Encode};
```
{% endcode %}

## Signatures

Vaults can cryptographically sign data. We support two types of Signatures: [EdDSA signatures using Curve 25519](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf) and [ECDSA signatures using SHA256 + Curve P-256](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf).

Our preferred signature scheme is EdDSA signatures using Curve 25519 which are also call Ed25519 signatures. ECDSA is only supported because as of this writing Cloud KMS services don't support Ed25519.

{% code lineNumbers="true" fullWidth="true" %}
```rust
/// A cryptographic signature.
#[derive(Encode, Decode)]
pub enum Signature {
    /// An EdDSA signature using Curve 25519.
    #[n(0)]
    EdDSACurve25519(#[n(0)] EdDSACurve25519Signature),

    /// An ECDSA signature using SHA-256 and Curve P-256.
    #[n(1)]
    ECDSASHA256CurveP256(#[n(0)] ECDSASHA256CurveP256Signature),
}

/// An EdDSA Signature using Curve25519.
///
/// - EdDSA Signature as defined [here][1].
/// - Curve25519 as defined in [here][2].
///
/// [1]: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf
/// [2]: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186.pdf
#[derive(Encode, Decode)]
#[cbor(transparent)]
pub struct EdDSACurve25519Signature(#[cbor(n(0), with = "minicbor::bytes")] pub [u8; 64]);

/// An ECDSA Signature using SHA256 and Curve P-256.
///
/// - ECDSA Signature as defined [here][1].
/// - SHA256 as defined [here][2].
/// - Curve P-256 as defined [here][3].
///
/// [1]: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf
/// [2]: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf
/// [3]: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186.pdf
#[derive(Encode, Decode)]
#[cbor(transparent)]
pub struct ECDSASHA256CurveP256Signature(#[cbor(n(0), with = "minicbor::bytes")] pub [u8; 64]);
```
{% endcode %}

## Public Keys

In addition to VerifyingPublicKeys for the above two signature schemes we also support X25519PublicKeys for ECDH in Ockam Secure Channels using [X25519](https://datatracker.ietf.org/doc/html/rfc7748).

{% code lineNumbers="true" fullWidth="true" %}
```rust
/// A public key for verifying signatures.
#[derive(Encode, Decode)]
pub enum VerifyingPublicKey {
    /// Curve25519 Public Key for verifying EdDSA signatures.
    #[n(0)]
    EdDSACurve25519(#[n(0)] EdDSACurve25519PublicKey),

    /// Curve P-256 Public Key for verifying ECDSA SHA256 signatures.
    #[n(1)]
    ECDSASHA256CurveP256(#[n(0)] ECDSASHA256CurveP256PublicKey),
}

/// A Curve25519 Public Key that is only used for EdDSA signatures.
///
/// - EdDSA Signature as defined [here][1] and [here][2].
/// - Curve25519 as defined [here][3].
///
/// [1]: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf
/// [2]: https://ed25519.cr.yp.to/papers.html
/// [2]: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186.pdf
#[derive(Encode, Decode)]
#[cbor(transparent)]
pub struct EdDSACurve25519PublicKey(#[cbor(n(0), with = "minicbor::bytes")] pub [u8; 32]);

/// A Curve P-256 Public Key that is only used for ECDSA SHA256 signatures.
///
/// This type only supports the uncompressed form which is 65 bytes and
/// has the first byte - 0x04. The uncompressed form is defined [here][1] in
/// section 2.3.3.
///
/// - ECDSA Signature as defined [here][2].
/// - SHA256 as defined [here][3].
/// - Curve P-256 as defined [here][4].
///
/// [1]: https://www.secg.org/SEC1-Ver-1.0.pdf
/// [2]: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf
/// [3]: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf
/// [4]: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186.pdf
#[derive(Encode, Decode)]
#[cbor(transparent)]
pub struct ECDSASHA256CurveP256PublicKey(#[cbor(n(0), with = "minicbor::bytes")] pub [u8; 65]);

/// X25519 Public Key is used for ECDH.
///
/// - X25519 as defined [here][1].
/// - Curve25519 as defined [here][2].
///
/// [1]: https://datatracker.ietf.org/doc/html/rfc7748
/// [2]: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186.pdf
#[derive(Encode, Decode)]
#[cbor(transparent)]
pub struct X25519PublicKey(#[cbor(n(0), with = "minicbor::bytes")] pub [u8; 32]);
```
{% endcode %}

## Vaults and Secrets

Three rust traits - `VaultForVerifyingSignatures`, `VaultForSigning`, and `VaultForSecureChannels` define abstract functions that an Ockam Vault implementation can implement to support Ockam Identities, Credentials, and Secure Channels.

Identities and Credentials require `VaultForVerifyingSignatures` and `VaultForSigning` while Secure Channels require `VaultForSecureChannels`.

#### VaultForVerifyingSignatures

Implementations of `VaultForVerifyingSignatures` provide two simple and stateless functions that don't require any secrets so they can be usually provided in software.

{% code lineNumbers="true" fullWidth="true" %}
```rust
use async_trait::async_trait;

pub struct Sha256Output([u8; 32]);

#[async_trait]
pub trait VaultForVerifyingSignatures: Send + Sync + 'static {
    async fn sha256(&self, data: &[u8]) -> Result<Sha256Output>;

    async fn verify_signature(
        &self,
        verifying_public_key: &VerifyingPublicKey,
        data: &[u8],
        signature: &Signature,
    ) -> Result<bool>;
}
```
{% endcode %}

#### VaultForSigning

Implementations of `VaultForSigning` enable using a secret signing key to sign Credentials, PurposeKeyAttestations, and Identity Change events. The signing key remains inside the tighter security boundary of a KMS or an HSM.

{% code lineNumbers="true" fullWidth="true" %}
```rust
use ockam_core::Result;

/// A handle to a secret inside a vault.
pub struct HandleToSecret(Vec<u8>);

/// A handle to a signing secret key inside a vault.
pub enum SigningSecretKeyHandle {
    /// Curve25519 key that is only used for EdDSA signatures.
    EdDSACurve25519(HandleToSecret),

    /// Curve P-256 key that is only used for ECDSA SHA256 signatures.
    ECDSASHA256CurveP256(HandleToSecret),
}

/// An enum to represent the supported types of signing keys.
pub enum SigningKeyType {
    // Curve25519 key that is only used for EdDSA signatures.
    EdDSACurve25519,

    /// Curve P-256 key that is only used for ECDSA SHA256 signatures.
    ECDSASHA256CurveP256,
}

#[async_trait]
pub trait VaultForSigning: Send + Sync + 'static {
    async fn sign(
        &self,
        signing_secret_key_handle: &SigningSecretKeyHandle,
        data: &[u8],
    ) -> Result<Signature>;

    async fn generate_signing_secret_key(
        &self,
        signing_key_type: SigningKeyType,
    ) -> Result<SigningSecretKeyHandle>;

    async fn get_verifying_public_key(
        &self,
        signing_secret_key_handle: &SigningSecretKeyHandle,
    ) -> Result<VerifyingPublicKey>;

    async fn get_secret_key_handle(
        &self,
        verifying_public_key: &VerifyingPublicKey,
    ) -> Result<SigningSecretKeyHandle>;

    async fn delete_signing_secret_key(
        &self,
        signing_secret_key_handle: SigningSecretKeyHandle,
    ) -> Result<bool>;
}
```
{% endcode %}

#### VaultForSecureChannels

Implementations of `VaultForSecureChannels` enable using a secret X25519 key for ECDH within Ockam Secure Channels. They rely on compile time feature flags to chose between three possible combinations of primitives:

* `OCKAM_XX_25519_AES256_GCM_SHA256` enables Ockam\_XX secure channel handshake with [AEAD\_AES\_256\_GCM](https://datatracker.ietf.org/doc/html/rfc5116#section-5.2) and SHA256. This is our current default.
* `OCKAM_XX_25519_AES128_GCM_SHA256` enables Ockam\_XX secure channel handshake with [AEAD\_AES\_128\_GCM](https://datatracker.ietf.org/doc/html/rfc5116#section-5.3) and SHA256.
* `OCKAM_XX_25519_ChaChaPolyBLAKE2s` enables Ockam\_XX secure channel handshake with [`AEAD_CHACHA20_POLY1305`](https://datatracker.ietf.org/doc/html/rfc7539#section-2.8) and [Blake2s](https://www.blake2.net/).

{% code lineNumbers="true" fullWidth="true" %}
```rust
use cfg_if::cfg_if;
use ockam_core::compat::{collections::BTreeMap, vec::Vec};

/// A handle to X25519 secret key inside a vault.
///
/// - X25519 as defined [here][1].
/// - Curve25519 as defined [here][2].
///
/// [1]: https://datatracker.ietf.org/doc/html/rfc7748
/// [2]: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186.pdf
pub struct X25519SecretKeyHandle(pub HandleToSecret);

pub struct SecretBufferHandle {
    pub handle: HandleToSecret,
    pub length: usize,
}

/// The number of hkdf outputs to produce from the hkdf function.
pub enum HKDFNumberOfOutputs {
    Two,
    Three,
}

cfg_if! {
    if #[cfg(feature = "OCKAM_XX_25519_ChaChaPolyBLAKE2s")] {
        pub struct Blake2sOutput([u8; 32]);
        pub struct HashOutput(pub Blake2sOutput);

        pub struct Blake2sHkdfOutput(Vec<SecretBufferHandle>);
        pub struct HkdfOutput(pub Blake2sHkdfOutput);

        pub struct Chacha20Poly1305SecretKeyHandle(pub HandleToSecret);
        pub struct AeadSecretKeyHandle(pub Chacha20Poly1305SecretKeyHandle);

    } else if #[cfg(feature = "OCKAM_XX_25519_AES128_GCM_SHA256")] {
        pub struct HashOutput(pub Sha256Output);

        pub struct Sha256HkdfOutput(Vec<SecretBufferHandle>);
        pub struct HkdfOutput(pub Sha256HkdfOutput);

        pub struct Aes128GcmSecretKeyHandle(pub HandleToSecret);
        pub struct AeadSecretKeyHandle(pub Aes128GcmSecretKeyHandle);

    } else {
        // OCKAM_XX_25519_AES256_GCM_SHA256
        pub struct HashOutput(pub Sha256Output);

        pub struct Sha256HkdfOutput(Vec<SecretBufferHandle>);
        pub struct HkdfOutput(pub Sha256HkdfOutput);

        pub struct Aes256GcmSecretKeyHandle(pub HandleToSecret);
        pub struct AeadSecretKeyHandle(pub Aes256GcmSecretKeyHandle);
    }
}

#[async_trait]
pub trait VaultForSecureChannels: Send + Sync + 'static {

    /// [1]: http://www.noiseprotocol.org/noise.html#dh-functions
    async fn dh(
        &self,
        secret_key_handle: &X25519SecretKeyHandle,
        peer_public_key: &X25519PublicKey,
    ) -> Result<SecretBufferHandle>;

    /// [1]: http://www.noiseprotocol.org/noise.html#hash-functions
    async fn hash(&self, data: &[u8]) -> Result<HashOutput>;

    /// [1]: http://www.noiseprotocol.org/noise.html#hash-functions
    async fn hkdf(
        &self,
        salt: &SecretBufferHandle,
        input_key_material: Option<&SecretBufferHandle>,
        number_of_outputs: HKDFNumberOfOutputs,
    ) -> Result<HkdfOutput>;

    /// AEAD Encrypt
    /// [1]: http://www.noiseprotocol.org/noise.html#cipher-functions
    async fn encrypt(
        &self,
        secret_key_handle: &AeadSecretKeyHandle,
        plain_text: &[u8],
        nonce: &[u8],
        aad: &[u8],
    ) -> Result<Vec<u8>>;

    /// AEAD Decrypt
    /// [1]: http://www.noiseprotocol.org/noise.html#cipher-functions
    async fn decrypt(
        &self,
        secret_key_handle: &AeadSecretKeyHandle,
        cipher_text: &[u8],
        nonce: &[u8],
        aad: &[u8],
    ) -> Result<Vec<u8>>;

    async fn generate_ephemeral_x25519_secret_key(&self) -> Result<X25519SecretKeyHandle>;

    async fn delete_ephemeral_x25519_secret_key(
        &self,
        secret_key_handle: X25519SecretKeyHandle,
    ) -> Result<bool>;

    async fn get_x25519_public_key(
        &self,
        secret_key_handle: &X25519SecretKeyHandle,
    ) -> Result<X25519PublicKey>;

    async fn get_x25519_secret_key_handle(
        &self,
        public_key: &X25519PublicKey,
    ) -> Result<X25519SecretKeyHandle>;

    async fn import_secret_buffer(&self, buffer: Vec<u8>) -> Result<SecretBufferHandle>;

    async fn delete_secret_buffer(&self, secret_buffer_handle: SecretBufferHandle) -> Result<bool>;

    async fn convert_secret_buffer_to_aead_key(
        &self,
        secret_buffer_handle: SecretBufferHandle,
    ) -> Result<AeadSecretKeyHandle>;

    async fn delete_aead_secret_key(&self, secret_key_handle: AeadSecretKeyHandle) -> Result<bool>;
}
```
{% endcode %}
