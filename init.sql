CREATE TABLE IF NOT EXISTS accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL
);

INSERT INTO accounts (username, password, email)
VALUES
    ('libby',
    'scrypt:32768:8:1$wONFC8ZM1TpEtL0o$d6b21211cf1d2b4c1e84b45905b8e070f25cb98a7448a6636598cb986570275e382ddbfcd668abef1fa35f66f11df889dfa05d78cff36db090d11f53dc89e09d',
    'libby@example.com'),
    ('sammy',
    'scrypt:32768:8:1$8qiRkCu9ZmzvVtNP$c43af89e4b210e23311143e067f497927639c5c7dda78e7105b17f2e46ce4529a1117e18dfd709d3952250ece611b5ed0f3cf1e8043089c366d60d21512cf59d',
    'sammy@example.com'),
    ('ethan',
    'scrypt:32768:8:1$jMTvoOwghnUdUrzK$c51712265c0771da99500ec94e8affb328308310c6a5f6cf9819064be3bbfce7dc64ae0f83ac9f465f31206183d85a723bc6b657acd2506bb689c00568632e8d',
    'ethan@example.com');