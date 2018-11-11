--CREATE TABLE
DROP SCHEMA IF EXISTS projet CASCADE;
CREATE SCHEMA projet;

CREATE TABLE projet.utilisateurs(
	id_utilisateur SERIAL PRIMARY KEY,
	email VARCHAR(50) NOT NULL CHECK (email SIMILAR TO '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}'),
	pseudo VARCHAR(20) NOT NULL UNIQUE CHECK (pseudo<>''),
	mot_de_passe VARCHAR(20) NOT NULL CHECK(mot_de_passe <> ''),
	status CHAR(1) NOT NULL CHECK(status IN ('N','A','M')),
	reputation INTEGER NOT NULL CHECK (reputation >= 0) DEFAULT 0,
	actif BOOLEAN NOT NULL DEFAULT('true')
);


CREATE TABLE projet.questions(
	no_question SERIAL PRIMARY KEY,
	titre VARCHAR(50) NOT NULL CHECK(titre <> ''),
	corps VARCHAR(1000) NOT NULL CHECK(corps <> ''),
	date_creation TIMESTAMP NOT NULL DEFAULT(NOW()),
	date_derniere_edition TIMESTAMP NULL CHECK(date_derniere_edition > date_creation),
	cloture BOOLEAN NOT NULL DEFAULT('false'),
	id_auteur_question INTEGER REFERENCES projet.utilisateurs (id_utilisateur) NOT NULL,
	id_editeur INTEGER REFERENCES projet.utilisateurs(id_utilisateur) NULL
);

CREATE TABLE projet.reponses(
	no_reponse SERIAL PRIMARY KEY,
	date_reponse TIMESTAMP NOT NULL,
	score INTEGER NOT NULL CHECK(score > 0),
	id_auteur_reponse INTEGER REFERENCES projet.utilisateurs(id_utilisateur) NOT NULL,
	reponse VARCHAR(200) NOT NULL CHECK(reponse <> '')
);

CREATE TABLE projet.reponse_votes(
	type_vote BOOLEAN NOT NULL,
	date_vote TIMESTAMP NOT NULL DEFAULT( NOW() ),
	id_voteur INTEGER REFERENCES projet.utilisateurs(id_utilisateur) NOT NULL,
	no_reponse INTEGER REFERENCES projet.reponses(no_reponse) NOT NULL,
	PRIMARY KEY (id_voteur,no_reponse)
);

CREATE TABLE projet.tags(
	id_tag SERIAL PRIMARY KEY,
	intitule VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE projet.tags_questions(
	no_question INTEGER REFERENCES projet.questions(no_question) NOT NULL,
	id_tag INTEGER REFERENCES projet.tags (id_tag) NOT NULL,
	PRIMARY KEY (no_question, id_tag)
);

--triggers

--trigger maj réputation
CREATE OR REPLACE FUNCTION projet.maj_reputaion() RETURNS TRIGGER AS $$
DECLARE
	ancienne_reputation INTEGER;
	id_utilisateur_a_maj INTEGER;
BEGIN
	if(NEW.type_vote = 'true')
	THEN
		--récupère l'id de l'utiisateur à mettre à jour
		SELECT R.id_auteur_reponse
		FROM projet.reponses R
		WHERE R.no_reponse = NEW.no_reponse
		INTO id_utilisateur_a_maj;

		--récupère l'ancienne réputation de l'utilisateur
		SELECT U.reputation
		FROM projet.utilisateurs U
		WHERE U.id_utilisateur = id_utilisateur_a_maj
		INTO ancienne_reputation;

		update projet.utilisateurs SET reputation = ancienne_reputation+5  WHERE id_utilisateur = id_utilisateur_a_maj;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_reputation
AFTER INSERT ON projet.reponse_votes FOR EACH ROW
EXECUTE PROCEDURE projet.maj_reputaion();

-- triger second 
--

--INSERT TABLE
--Utilisateur
INSERT INTO projet.utilisateurs VALUES (DEFAULT, 'V.Buccili@gmail.com', 'VinzThePrincE', 'Ker!321', 'M', DEFAULT, 'true');
INSERT INTO projet.utilisateurs VALUES (DEFAULT, 'Y.Ozturk@gmail.com', 'skr213', 'skr213', 'M', 120, 'true');
INSERT INTO projet.utilisateurs VALUES (DEFAULT, 'S.Hafidi@gmail.com', 'shafidi', 'sam213', 'N', DEFAULT, 'true');
INSERT INTO projet.utilisateurs VALUES (DEFAULT, 'S.Ghambir@gmail.com', 'sghambir', 'sghambir123', 'A', 55, 'true');
INSERT INTO projet.utilisateurs VALUES (DEFAULT, 'testDesactive@gmail.com', 'testDesactive', 'testDesactive', 'A', DEFAULT, 'false');

--Question
INSERT INTO projet.questions VALUES (DEFAULT, 'BESOIN D''AIDE', 'Bonjour je sais pas comment on print , bien à vous', DEFAULT, NULL, 'false', 2, NULL);
INSERT INTO projet.questions VALUES (DEFAULT, 'HELP PLS', 'J''AI UN PROJET JE SUIS PERDU, bien à vous', NOW(), NULL, 'true', 2, 1);
INSERT INTO projet.questions VALUES (DEFAULT, 'Question sur les pointeurs C', 'Salut à tous, je souhaiterais connaître la signification d''un pointeur Merci', '2018-09-15', NOW() , 'false', 1, 2);
INSERT INTO projet.questions VALUES (DEFAULT, 'Comment faire une requête SQL ?', 'Je suis assez perdu en SQL, pouvez-vous m''aider ?', '2018-10-15', NOW() , 'true', 3, 1);


--Réponses 
INSERT INTO projet.reponses VALUES (DEFAULT, NOW(), 2, 2, 'Hey toi qui es nul, j''ai la bonne réponse moi !');
INSERT INTO projet.reponses VALUES (DEFAULT, NOW(), 3, 1, 'Via Un SELECT cordialement');
INSERT INTO projet.reponses VALUES (DEFAULT, NOW(), 1, 3, 'Je suis Udini');

-- Réponses-votes 
INSERT INTO projet.reponse_votes VALUES ('false', NOW(), 2, 1);
INSERT INTO projet.reponse_votes VALUES ('true', NOW(), 4, 2);
INSERT INTO projet.reponse_votes VALUES ('false', NOW(), 3, 3);

-- Tags
INSERT INTO projet.tags VALUES (DEFAULT, '#SQL');
INSERT INTO projet.tags VALUES (DEFAULT, '#C++');
INSERT INTO projet.tags VALUES (DEFAULT, '#JAVA');
INSERT INTO projet.tags VALUES (DEFAULT, '#C');
INSERT INTO projet.tags VALUES (DEFAULT, '#Python');
INSERT INTO projet.tags VALUES (DEFAULT, '#PHP');

-- Tags_questions
INSERT INTO projet.tags_questions VALUES (1, 3);
INSERT INTO projet.tags_questions VALUES (3, 4);
INSERT INTO projet.tags_questions VALUES (4, 1);

































