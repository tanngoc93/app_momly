#!/bin/bash
set -e

# Start Ollama in the background.
/bin/ollama serve &
# Record Process ID.
pid=$!

# Pause for Ollama to start.
sleep 5

echo "🔴 Retrieve [gemma:2b-instruct] model..."
ollama run gemma:2b-instruct
echo "🟢 Done!"

# Wait for Ollama process to finish.
wait $pid

exec "$@"