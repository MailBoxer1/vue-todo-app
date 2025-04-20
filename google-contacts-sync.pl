#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Net::Google::OAuth2;
use LWP::UserAgent;
use JSON;
use XML::Simple;
use Data::Dumper;

# Конфигурация для доступа к Google API
my $client_id = 'YOUR_CLIENT_ID';
my $client_secret = 'YOUR_CLIENT_SECRET';
my $redirect_uri = 'urn:ietf:wg:oauth:2.0:oob';  # для приложений командной строки
my $scope = 'https://www.googleapis.com/auth/contacts';

# Конфигурация базы данных (SQLite для демонстрации)
my $db_file = 'contacts.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "", { RaiseError => 1 });

# Создаем таблицу контактов, если она не существует
$dbh->do("CREATE TABLE IF NOT EXISTS contacts (
    id TEXT PRIMARY KEY,
    name TEXT,
    email TEXT,
    phone TEXT,
    last_updated TEXT
)");

# Инициализация OAuth2 для Google
my $oauth2 = Net::Google::OAuth2->new(
    client_id => $client_id,
    client_secret => $client_secret,
    redirect_uri => $redirect_uri
);

# Получение токена доступа (при первом запуске потребуется интерактивное подтверждение)
my $auth_url = $oauth2->authorization_url(scope => $scope);
print "Перейдите по следующей ссылке и авторизуйте приложение:\n$auth_url\n";
print "Введите код авторизации: ";
my $auth_code = <STDIN>;
chomp $auth_code;

my $token = $oauth2->exchange(code => $auth_code);
my $access_token = $token->{access_token};

# Функция для получения списка контактов из Google
sub get_google_contacts {
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->get(
        'https://www.google.com/m8/feeds/contacts/default/full?alt=json&max-results=10000',
        'Authorization' => "Bearer $access_token"
    );
    
    if ($resp->is_success) {
        my $content = $resp->content;
        my $json = decode_json($content);
        
        my @contacts;
        foreach my $entry (@{$json->{feed}{entry}}) {
            next unless defined $entry->{gd$email};
            
            my $contact_id = $entry->{id}{'\$t'};
            $contact_id =~ s/.*\/base\///;  # Извлекаем только ID
            
            my $name = $entry->{title}{'\$t'} || '';
            my $email = '';
            my $phone = '';
            
            # Извлекаем первый email
            if (defined $entry->{gd$email} && ref $entry->{gd$email} eq 'ARRAY') {
                $email = $entry->{gd$email}[0]{address} || '';
            }
            
            # Извлекаем первый телефон, если есть
            if (defined $entry->{gd$phoneNumber} && ref $entry->{gd$phoneNumber} eq 'ARRAY') {
                $phone = $entry->{gd$phoneNumber}[0]{'\$t'} || '';
            }
            
            push @contacts, {
                id => $contact_id,
                name => $name,
                email => $email,
                phone => $phone
            };
        }
        
        return \@contacts;
    } else {
        die "Ошибка получения контактов: " . $resp->status_line;
    }
}

# Функция для получения списка контактов из локальной базы
sub get_db_contacts {
    my $sth = $dbh->prepare("SELECT id, name, email, phone FROM contacts");
    $sth->execute();
    
    my %contacts;
    while (my $row = $sth->fetchrow_hashref) {
        $contacts{$row->{id}} = $row;
    }
    
    return \%contacts;
}

# Функция для добавления или обновления контакта в базе
sub update_contact_in_db {
    my ($contact) = @_;
    
    my $sth = $dbh->prepare(
        "INSERT OR REPLACE INTO contacts (id, name, email, phone, last_updated) 
         VALUES (?, ?, ?, ?, datetime('now'))"
    );
    
    $sth->execute(
        $contact->{id},
        $contact->{name},
        $contact->{email},
        $contact->{phone}
    );
    
    print "Контакт обновлен/добавлен в БД: $contact->{name} ($contact->{email})\n";
}

# Функция для удаления контакта из базы
sub delete_contact_from_db {
    my ($contact_id) = @_;
    
    my $sth = $dbh->prepare("DELETE FROM contacts WHERE id = ?");
    $sth->execute($contact_id);
    
    print "Контакт удален из БД: ID = $contact_id\n";
}

# Функция для добавления нового контакта в Google
sub add_contact_to_google {
    my ($name, $email, $phone) = @_;
    
    my $xml = qq{
        <atom:entry xmlns:atom='http://www.w3.org/2005/Atom'
            xmlns:gd='http://schemas.google.com/g/2005'>
          <atom:category scheme='http://schemas.google.com/g/2005#kind'
            term='http://schemas.google.com/contact/2008#contact' />
          <atom:title>$name</atom:title>
          <gd:email rel='http://schemas.google.com/g/2005#work'
            primary='true'
            address='$email' />
    };
    
    if ($phone) {
        $xml .= qq{
          <gd:phoneNumber rel='http://schemas.google.com/g/2005#work'
            primary='true'>$phone</gd:phoneNumber>
        };
    }
    
    $xml .= qq{</atom:entry>};
    
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->post(
        'https://www.google.com/m8/feeds/contacts/default/full',
        'Authorization' => "Bearer $access_token",
        'Content-Type' => 'application/atom+xml',
        'Content' => $xml
    );
    
    if ($resp->is_success) {
        my $content = $resp->content;
        my $xs = XML::Simple->new();
        my $ref = $xs->XMLin($content);
        
        my $contact_id = $ref->{id};
        $contact_id =~ s/.*\/base\///;  # Извлекаем только ID
        
        print "Контакт добавлен в Google: $name ($email), ID = $contact_id\n";
        
        # Добавляем контакт и в локальную базу
        update_contact_in_db({
            id => $contact_id,
            name => $name,
            email => $email,
            phone => $phone
        });
        
        return $contact_id;
    } else {
        die "Ошибка добавления контакта: " . $resp->status_line;
    }
}

# Функция для удаления контакта из Google
sub delete_contact_from_google {
    my ($contact_id) = @_;
    
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->delete(
        "https://www.google.com/m8/feeds/contacts/default/full/$contact_id",
        'Authorization' => "Bearer $access_token",
        'If-Match' => '*'  # Необходимо для удаления контакта
    );
    
    if ($resp->is_success) {
        print "Контакт удален из Google: ID = $contact_id\n";
        return 1;
    } else {
        die "Ошибка удаления контакта: " . $resp->status_line;
    }
}

# Основная функция синхронизации
sub sync_contacts {
    print "Получение контактов из Google...\n";
    my $google_contacts = get_google_contacts();
    
    print "Получение контактов из локальной базы данных...\n";
    my $db_contacts = get_db_contacts();
    
    # Обновляем или добавляем контакты из Google в базу
    foreach my $contact (@$google_contacts) {
        update_contact_in_db($contact);
    }
    
    # Находим контакты, которые есть в базе, но отсутствуют в Google - их нужно удалить
    my %google_ids = map { $_->{id} => 1 } @$google_contacts;
    foreach my $id (keys %$db_contacts) {
        if (!exists $google_ids{$id}) {
            delete_contact_from_db($id);
        }
    }
    
    print "Синхронизация завершена успешно.\n";
}

# Демонстрационная часть
print "=== Демонстрация синхронизации контактов Google ===\n\n";

# Синхронизируем текущие контакты
print "Шаг 1: Синхронизация текущих контактов\n";
sync_contacts();
print "\n";

# Добавляем новый контакт в Google
print "Шаг 2: Добавление нового контакта в Google\n";
my $new_contact_id = add_contact_to_google(
    "Тестовый Контакт", 
    "test.contact" . time() . "@example.com", 
    "+7 999 123-45-67"
);
print "\n";

# Синхронизируем еще раз, чтобы увидеть новый контакт в базе
print "Шаг 3: Повторная синхронизация\n";
sync_contacts();
print "\n";

# Удаляем контакт из Google
print "Шаг 4: Удаление контакта из Google\n";
if ($new_contact_id) {
    delete_contact_from_google($new_contact_id);
    # Также удаляем его из локальной базы
    delete_contact_from_db($new_contact_id);
}
print "\n";

# Завершение
print "Демонстрация завершена.\n";
$dbh->disconnect();

__END__

=head1 NAME

google-contacts-sync.pl - Синхронизация контактов Google с локальной базой данных

=head1 DESCRIPTION

Скрипт для синхронизации контактов Google с локальной базой данных SQLite.
Демонстрирует:
- Аутентификацию в Google API с использованием OAuth2
- Получение списка контактов
- Синхронизацию с локальной базой данных
- Добавление нового контакта
- Удаление контакта

=head1 PREREQUISITES

Для работы скрипта требуются следующие модули Perl:
- DBI и DBD::SQLite для работы с базой данных
- Net::Google::OAuth2 для авторизации
- LWP::UserAgent для HTTP-запросов
- JSON и XML::Simple для работы с данными
- Data::Dumper для отладки

=head1 USAGE

1. Зарегистрируйте приложение в Google Cloud Console и получите Client ID и Client Secret
2. Укажите полученные данные в переменных $client_id и $client_secret
3. Запустите скрипт: perl google-contacts-sync.pl
4. При первом запуске следуйте инструкциям для авторизации

=head1 AUTHOR

Example Author <example@example.com>

=cut 