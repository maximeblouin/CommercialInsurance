import os
import numpy as np
from collections import Counter
import re
import csv

def read_sas_programs(directory):
    sas_contents = {}
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.sas'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    content = f.read()
                    content = preprocess_content(content)
                    sas_contents[file_path] = content
    return sas_contents

def preprocess_content(content):
    lines = content.splitlines()
    cleaned_lines = []
    for line in lines:
        cleaned_line = line.strip()  # Remove leading and trailing spaces
        cleaned_line = cleaned_line.lstrip('\t')  # Remove leading tabs
        if cleaned_line:  # Remove blank lines
            cleaned_lines.append(cleaned_line.upper())  # Convert to uppercase
    return ' '.join(cleaned_lines)

def tokenize(text):
    tokens = re.findall(r'\b\w+\b', text)
    return tokens

def vectorize(tokens, vocab):
    vector = np.zeros(len(vocab))
    token_counts = Counter(tokens)
    for token, count in token_counts.items():
        if token in vocab:
            vector[vocab[token]] = count
    return vector

def build_vocab(sas_contents):
    vocab = {}
    index = 0
    for content in sas_contents.values():
        tokens = tokenize(content)
        for token in tokens:
            if token not in vocab:
                vocab[token] = index
                index += 1
    return vocab

def calculate_similarity(sas_contents):
    vocab = build_vocab(sas_contents)
    vectors = []
    for content in sas_contents.values():
        tokens = tokenize(content)
        vector = vectorize(tokens, vocab)
        vectors.append(vector)
    vectors = np.array(vectors)
    
    similarity_matrix = np.zeros((len(vectors), len(vectors)))
    for i in range(len(vectors)):
        for j in range(i + 1, len(vectors)):  # Skip duplicated comparisons
            similarity_matrix[i][j] = cosine_similarity(vectors[i], vectors[j])
    return similarity_matrix, list(sas_contents.keys())

def cosine_similarity(vector1, vector2):
    dot_product = np.dot(vector1, vector2)
    norm1 = np.linalg.norm(vector1)
    norm2 = np.linalg.norm(vector2)
    if norm1 == 0 or norm2 == 0:
        return 0.0
    return dot_product / (norm1 * norm2)

def write_similarity_to_csv(similarity_matrix, filenames, output_file):
    with open(output_file, mode='w', newline='') as file:
        writer = csv.writer(file)
        header = ['File 1', 'File 2', 'Similarity']
        writer.writerow(header)
        n = len(filenames)
        for i in range(n):
            for j in range(i + 1, n):
                writer.writerow([filenames[i], filenames[j], f"{similarity_matrix[i][j]:.2f}"])

def main(directory, output_file):
    sas_contents = read_sas_programs(directory)
    similarity_matrix, filenames = calculate_similarity(sas_contents)
    write_similarity_to_csv(similarity_matrix, filenames, output_file)

# Replace 'your_directory_path' with the path to your directory containing SAS programs
# Replace 'output_file.csv' with the desired output file path
main('your_directory_path', 'output_file.csv')
