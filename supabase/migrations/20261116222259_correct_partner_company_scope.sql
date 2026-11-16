-- Moema and Morumbi belong to the normal store login, not partner entry.
update public.partner_companies set is_active=false where brand_id='2f7d8451-b279-4d69-8192-6ac9953d7da1' and slug in ('moema','morumbi','revendas');
update public.partner_companies set name='Track n'' Field' where brand_id='2f7d8451-b279-4d69-8192-6ac9953d7da1' and slug='track-n-field';
