# How to access these docs from ChatGPT, Cursor, etc

🔗 **Ockam's docs are LLM-ready**: You can use `https://docs.ockam.io/llms-full.txt` to prompt large language models to understand and reason about Ockam using official documentation.

### How to Use Ockam's `llms-full.txt` with ChatGPT and Cursor

You can prompt AI tools to use Ockam's documentation by referencing our [LLM-ready index](https://docs.ockam.io/llms-full.txt). This helps large language models answer your questions using trusted, up-to-date information.

#### For ChatGPT (Pro users with GPT-4o)

1. Open [ChatGPT](https://chat.openai.com) and select **GPT-4o**.
2.  Paste the following prompt:

    {% code fullWidth="true" %}
    ```
    Use the full documentation at https://docs.ockam.io/llms-full.txt to answer questions about Ockam.
    ```
    {% endcode %}
3.  Then ask your question. For example:

    ```
    Can I bring my own HSM or Key Vault to store Ockam keys?
    ```

ChatGPT will now reference the docs listed in `llms-full.txt` to give more accurate answers.

***

#### ✅ For Cursor (AI coding editor)

Cursor supports web context and documentation lookups.

1. Open Cursor and activate the chat (Cmd+K or click the Chat icon).
2.  Type:

    ```
    Use the full documentation at https://docs.ockam.io/llms-full.txt to help me with Ockam.
    ```
3.  Ask follow-up questions like:

    ```
    Have the Ockam protocols been independently audited by cryptogrpahy experts? 
    ```

Cursor will incorporate the docs into its responses, making code completions and suggestions more relevant to Ockam.

***

#### 🔍 What is `llms-full.txt`?

This file is part of the **Model Context Protocol (MCP)** — a standard that allows developers to expose their full documentation to AI tools in a structured way.&#x20;
