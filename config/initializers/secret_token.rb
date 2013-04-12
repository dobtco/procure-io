# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ProcureIo::Application.config.secret_token = ENV['SECRET_TOKEN'] || "98984c304f5815d1c3862ebd0333590b2f5bd90115edbfea8ad0cda843156d7122f3a43e7cdec119300fbe5228eba4f8acce32138185d305c52847b73d527533"
