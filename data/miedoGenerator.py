import os
#import openai
from openai import OpenAI
from gtts import gTTS

client = OpenAI()

client.api_key = "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"


# myPrompt = "What dinosaurs lived in the cretaceous period?"
# tokens = 60
# temp = 0.7

# conversation = [{
#   "role": "system", "content": "you are a flattered AI assistant."
#   }
#   ]

def get_response (myPrompt, tokens, temp):
    #response= openai.Completion.create(
    response= client.completions.create(
        model="text-davinci-003",
        #messages=conversation,
        prompt=myPrompt,
        max_tokens=tokens,
        temperature=temp
    )
    return response.choices[0].text.strip()

#get_response("crea un elogio literario de Kafka", 50, 0.5)
