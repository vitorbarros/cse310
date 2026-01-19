# Overview

I built this project to strengthen my Rust skills by implementing a small but complete web service. The goal was to practice Rust syntax, ownership patterns, and common web development workflows while producing a runnable application.

The software is a basic REST API that manages tasks in memory. Each task has a generated id, a title, and a completed flag, and the API supports creating, reading, updating, and deleting tasks.

I wrote this to get hands-on practice with Rust fundamentals (structs, enums, ownership, concurrency primitives) while also learning how to wire up a simple HTTP server using common libraries.

[Software Demo Video](https://youtu.be/nLwXhuP9ROA)

# Development Environment

I used macOS with VS Code, the Rust toolchain (rustc and Cargo), and curl for testing endpoints.

The project is written in Rust and uses the Axum web framework, Tokio for async runtime, and Serde for JSON serialization.

# Useful Websites

- [Rust Book](https://doc.rust-lang.org/book/)
- [Axum Documentation](https://docs.rs/axum/latest/axum/)
- [Tokio Documentation](https://docs.rs/tokio/latest/tokio/)

# Future Work

- Add persistent storage so tasks survive server restarts.
- Add input validation and better error messages.
- Add tests for the REST endpoints.
