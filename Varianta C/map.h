#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 100

// Define a structure for key-value pairs
typedef struct
{
    char *key;
    int value;
} KeyValuePair;

// Define a structure for a linked list node
typedef struct Node
{
    KeyValuePair data;
    struct Node *next;
} Node;

// Define a structure for the hashmap
typedef struct
{
    Node *buckets[TABLE_SIZE];
} HashMap;

// Function to create a new key-value pair
KeyValuePair *createKeyValuePair(const char *key, int value)
{
    KeyValuePair *pair = (KeyValuePair *)malloc(sizeof(KeyValuePair));
    pair->key = strdup(key);
    pair->value = value;
    return pair;
}

// Function to create a new node
Node *createNode(KeyValuePair *data)
{
    Node *newNode = (Node *)malloc(sizeof(Node));
    newNode->data = *data;
    newNode->next = NULL;
    return newNode;
}

// Function to hash a string and get an index
unsigned int hashFunction(const char *key)
{
    unsigned int hash = 0;
    while (*key)
    {
        hash = (hash << 5) + *key++;
    }
    return hash % TABLE_SIZE;
}

// Function to insert a key-value pair into the hashmap
void insert(HashMap *map, const char *key, int value)
{
    unsigned int index = hashFunction(key);
    KeyValuePair *pair = createKeyValuePair(key, value);
    Node *newNode = createNode(pair);

    // Insert at the beginning of the linked list
    newNode->next = map->buckets[index];
    map->buckets[index] = newNode;
}

// Function to retrieve the value associated with a key
int get(HashMap *map, const char *key)
{
    unsigned int index = hashFunction(key);
    Node *current = map->buckets[index];

    // Traverse the linked list at the given index
    while (current != NULL)
    {
        if (strcmp(current->data.key, key) == 0)
        {
            return current->data.value; // Key found, return the associated value
        }
        current = current->next;
    }

    return -1; // Key not found
}

void put(HashMap *map, const char *key, int value)
{
    unsigned int index = hashFunction(key);
    Node *current = map->buckets[index];

    // Check if the key already exists in the hashmap
    while (current != NULL)
    {
        if (strcmp(current->data.key, key) == 0)
        {
            // Key found, update the value and return
            current->data.value = value;
            return;
        }
        current = current->next;
    }

    // If the key is not found, insert a new key-value pair
    insert(map, key, value);
}

// Function to delete a key-value pair from the hashmap
void delete(HashMap *map, const char *key)
{
    unsigned int index = hashFunction(key);
    Node *current = map->buckets[index];
    Node *prev = NULL;

    // Traverse the linked list at the given index
    while (current != NULL)
    {
        if (strcmp(current->data.key, key) == 0)
        {
            // Found the key, remove the node from the list
            if (prev == NULL)
            {
                // The node is the first in the list
                map->buckets[index] = current->next;
            }
            else
            {
                prev->next = current->next;
            }

            // Free memory allocated for key and node
            free(current->data.key);
            free(current);
            return;
        }

        prev = current;
        current = current->next;
    }
}

int contains(HashMap *map, const char *word)
{
    for (int i = 0; i < TABLE_SIZE; ++i)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            if (strstr(current->data.key, word) != NULL)
            {
                return 1;
            }
            current = current->next;
        }
    }
    return 0;
}

int getValue(HashMap *map, const char *word)
{
    for (int i = 0; i < TABLE_SIZE; ++i)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            if (strstr(current->data.key, word) != NULL)
            {
                return current->data.value;
            }
            current = current->next;
        }
    }
    return -1;
}

char *getKeyByWord(const HashMap *map, const char *word)
{
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            if (strstr(current->data.key, word) != NULL)
            {
                return current->data.key;
            }
            current = current->next;
        }
    }
    return NULL;
}

void destroyHashMap(HashMap *map)
{
    for (int i = 0; i < TABLE_SIZE; ++i)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            Node *next = current->next;
            free(current->data.key);
            free(current);
            current = next;
        }
    }
}

void printHashMap(HashMap *map)
{
    for (int i = 0; i < TABLE_SIZE; ++i)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            printf("Key: \"%s\", Value: %d\n", current->data.key, current->data.value);
            current = current->next;
        }
    }
}