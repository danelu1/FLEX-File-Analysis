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

int contains(HashMap *map, const char *word)
{
    for (int i = 0; i < TABLE_SIZE; ++i)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            char *text = strstr(current->data.key, word);
            if (text != NULL && ((text + strlen(word))[0] == ' ' || (text + strlen(word))[0] == '\0'))
            {
                return 1;
            }

            current = current->next;
        }
    }

    return 0;
}

int getValue(HashMap *map, char *word)
{
    for (int i = 0; i < TABLE_SIZE; ++i)
    {
        Node *current = map->buckets[i];
        while (current != NULL)
        {
            char *text = strstr(current->data.key, word);
            if (text != NULL && ((text + strlen(word))[0] == ' ' || (text + strlen(word))[0] == '\0'))
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