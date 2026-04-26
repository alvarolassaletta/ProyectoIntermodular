
-- ------------------------
--       TIME-ENTRIES 
---------------------------

CREATE TABLE public.time_entries(
        id UUID DEFAULT gen_random_uuid(), 
        user_id UUID REFERENCES profiles(id) NOT NULL, 
        clock_in TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        clock_out TIMESTAMP WITH TIME ZONE, 
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        PRIMARY KEY(id)
);


--Activacion de RLS.  Si se crean mas tablas  hay que activar tambien RLS manualmente  usando esta linea despues de la tabla que se cree

ALTER TABLE time_entries ENABLE ROW LEVEL SECURITY; 

---------------------
-- POLICIES 
---------------------

--Para las policies se  sigue las estructura de POSTGRESS. La documentación de Supabase recomenienda añadir TO authenticated y envolver la funcion auth.uid en un SELECT para mejorar rendimiento 

--     TIME  ENTRIES 

--Politica de lectura  de los registros 
CREATE POLICY "Users can view  their own  time entries" 
ON time_entries
FOR SELECT  
TO authenticated 
USING ( (SELECT auth.uid())= user_id); 

--Si administrador puede ver todos los registros 
CREATE POLICY "Admins can view all  time_entries "
ON time_entries
FOR SELECT 
TO authenticated 
USING ((SELECT public.is_admin()));


--Política de insercción 
--En INSERT hay que usar WITH CHECK y no USING
CREATE POLICY "Users can insert their own time entries" 
ON time_entries
FOR INSERT 
TO authenticated 
WITH CHECK((SELECT auth.uid())= user_id);


--Politica de actualización . Se puede hacer el update pra hacer el registro de salida, que  hasta que no sea haga es null
CREATE POLICY "Users can update their own time entries ONLY to clock out." ON time_entries
FOR UPDATE 
TO authenticated 
USING ( (select auth.uid()) = user_id AND clock_out IS NULL )
WITH CHECK ( (select auth.uid()) = user_id );


-- Acelera todas las consultas filtradas por usuario
CREATE INDEX idx_time_entries_user_id ON time_entries(user_id);

-- Incide para  getActiveTimeEntry (busca clock_out IS NULL de un usuario)
CREATE INDEX idx_time_entries_user_clock_out ON time_entries(user_id, clock_out);

-- Indice par getTimeEntriesByDateRange (filtra por usuario y rango de fechas)
CREATE INDEX idx_time_entries_user_clock_in ON time_entries(user_id, clock_in);