# Example Mock API Call to AI Service

def mock_generate_response(prompt: str):
    """
    Simulates a call to an LLM.
    Useful for testing backend integration without using real credits.
    """
    print(f"Received prompt: {prompt}")
    
    # Simulate network latency
    # import time; time.sleep(1)
    
    return {
        "status": "success",
        "data": {
            "content": "This is a mocked response derived from the AI service.",
            "usage": {"prompt_tokens": 10, "completion_tokens": 5}
        }
    }

if __name__ == "__main__":
    result = mock_generate_response("Hello world")
    print(result)
