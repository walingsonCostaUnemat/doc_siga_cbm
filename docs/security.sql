
CREATE TABLE sec_users (
    login CHARACTER VARYING(255)   NOT NULL,
    pswd CHARACTER VARYING(255)   NOT NULL,
    name CHARACTER VARYING(255) ,
    email CHARACTER VARYING(255) ,
    active CHARACTER VARYING(1) ,
    activation_code CHARACTER VARYING(32) ,
    priv_admin CHARACTER VARYING(1) ,
    mfa CHARACTER VARYING(255) ,
    picture BYTEA,
    role CHARACTER VARYING(128) ,
    phone CHARACTER VARYING(64) ,
    pswd_last_updated TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    mfa_last_updated TIMESTAMP(6) DEFAULT NULL,
    PRIMARY KEY (login)
)


CREATE TABLE sec_apps (
    app_name CHARACTER VARYING(128)   NOT NULL,
    app_type CHARACTER VARYING(255),
    description CHARACTER VARYING(255) ,
    PRIMARY KEY (app_name)
)


CREATE TABLE sec_groups (
    group_id SERIAL   NOT NULL,
    description CHARACTER VARYING(255) ,
    PRIMARY KEY (group_id)
)


CREATE TABLE sec_users_groups (
    login CHARACTER VARYING(255)   NOT NULL,
    group_id INTEGER   NOT NULL,
    PRIMARY KEY (login, group_id)
)

ALTER TABLE sec_users_groups ADD CONSTRAINT users_groups_ibfk_1 FOREIGN KEY (login) REFERENCES sec_users (login) ON DELETE CASCADE

ALTER TABLE sec_users_groups ADD CONSTRAINT users_groups_ibfk_2 FOREIGN KEY (group_id) REFERENCES sec_groups (group_id) ON DELETE CASCADE


CREATE TABLE sec_groups_apps (
    group_id INTEGER   NOT NULL,
    app_name CHARACTER VARYING(128)   NOT NULL,
    priv_access CHARACTER VARYING(1) ,
    priv_insert CHARACTER VARYING(1) ,
    priv_delete CHARACTER VARYING(1) ,
    priv_update CHARACTER VARYING(1) ,
    priv_export CHARACTER VARYING(1) ,
    priv_print CHARACTER VARYING(1) ,
    PRIMARY KEY (group_id, app_name)
)

ALTER TABLE sec_groups_apps ADD CONSTRAINT groups_apps_ibfk_1 FOREIGN KEY (group_id) REFERENCES sec_groups (group_id) ON DELETE CASCADE

ALTER TABLE sec_groups_apps ADD CONSTRAINT groups_apps_ibfk_2 FOREIGN KEY (app_name) REFERENCES sec_apps (app_name) ON DELETE CASCADE


CREATE TABLE sec_settings (
    set_name CHARACTER VARYING(255)  NOT NULL,
    set_value CHARACTER VARYING(255),
    PRIMARY KEY (set_name)
)
CREATE TABLE "sec_logged" (
    login CHARACTER VARYING(255)  NOT NULL,
    date_login CHARACTER VARYING(128),
    sc_session CHARACTER VARYING(128),
    ip CHARACTER VARYING(255)
)
