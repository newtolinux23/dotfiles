import openai
import os

# Load your OpenAI API key from environment variables
openai.api_key = os.getenv("OPENAI_API_KEY")

def chat_with_gpt(prompt):
    response = openai.Completion.create(
        engine="text-davinci-003",
        prompt=prompt,
        max_tokens=150
    )
    return response.choices[0].text.strip()

def main():
    print("ChatGPT Terminal. Type 'exit' to quit.")
    while True:
        user_input = input("You: ")
        if user_input.lower() == 'exit':
            break
        response = chat_with_gpt(user_input)
        print(f"ChatGPT: {response}")

if __name__ == "__main__":
    main()
