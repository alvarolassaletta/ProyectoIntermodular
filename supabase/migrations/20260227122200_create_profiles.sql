
-- ------------------------
--     PROFILES 
---------------------------

CREATE TABLE public.profiles (
        id UUID REFERENCES auth.users, 
        user_name TEXT, 
        full_name TEXT, 
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        is_admin BOOLEAN DEFAULT false,
        email TEXT NOT NULL

        PRIMARY KEY(id),
        CONSTRAINT  user_name_length CHECK(char_length(user_name) >=8)
);

--Activacion de RLS.  Si se crean mas tablas  hay que activar tambien RLS manualmente  usando esta linea despues de la tabla que se cree
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY; 


---------------------
-- POLICIES 
---------------------

--Para las policies se  sigue las estructura de POSTGRESS. La documentación de Supabase recomenienda añadir TO authenticated y envolver la funcion auth.uid en un SELECT para mejorar rendimiento 

--     PROFILES 

--politica de Lectura ( SELECT)
CREATE POLICY "Users can view  their own profile" 
ON profiles 
FOR SELECT  
TO authenticated 
USING ( (SELECT auth.uid())= id); 

-- si es administrador puede ver todos los perfiles 
CREATE POLICY "Admins can view all profiles"
ON profiles 
FOR SELECT 
TO authenticated 
USING ((SELECT public.is_admin()));

--Política de insercción 
CREATE POLICY "Users can insert their own profile" 
ON profiles 
FOR INSERT 
TO authenticated 
WITH CHECK ( (SELECT auth.uid())= id);

--Política de actualización 
CREATE POLICY "Users can update their  own  profile" 
ON profiles 
FOR UPDATE 
TO authenticated 
USING ( (SELECT auth.uid()) = id )       
WITH CHECK ( (SELECT auth.uid()) = id );  

--No es necesario una politica para DELETE. No queremos que el usuario pueda borrar su propio perfil


-- Este trigger se dispara cuando  hay un nuevo sign up. Esto es,  se inserta un user en la tabla interna  que supabase usa para la autentificación 
--cuando ocurre la inserccion se llama a la funcion handle_new_user 
CREATE TRIGGER  on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH  ROW EXECUTE PROCEDURE  public.handle_new_user();

-- Acelera busquedas por email y  evita  duplicidad de perfiles con el mismo email
CREATE UNIQUE INDEX idx_profiles_email ON profiles(email);