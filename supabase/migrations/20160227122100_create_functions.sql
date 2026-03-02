
/*https://supabase.com/docs/guides/auth/managing-user-data?queryGroups=language&language=dart*/
-------------------------
-- FUNCIONES POSTGRESS 
-------------------------

--Funcion para comprobar si el usuario es adminsitrador
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  -- Leemos el campo is_admin del usuario que hace la petición
   RETURN (SELECT is_admin FROM public.profiles WHERE id = auth.uid());
END;
$$ LANGUAGE  plpgsql  SECURITY DEFINER;


--Cuando se haga sign up se  hace una inseccion en auth.users y  se hara un INSERT en profiles 
--la informacion guardada en auth.users  'viaja' en la variable new 
--cuando se haga el signUp habra que mandar tb el  user_name y full_name, que se guardaran en raw_user_meta_data dentro de auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS  trigger AS  $$
BEGIN 
        INSERT INTO  public.profiles (id, full_name, user_name)
        VALUES (
                new.id, 
                new.raw_user_meta_data ->> 'full_name', 
                new.raw_user_meta_data ->> 'user_name');
        RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 

