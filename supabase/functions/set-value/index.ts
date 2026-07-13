// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "jsr:@supabase/server@^1";

interface ReqPayload {
  name: string;
  key: string;
  value: string;
}

console.info("server started");

export default {
  fetch: withSupabase({ auth: 'publishable' }, async (req, ctx) => {
    const {name, key, value }: ReqPayload = await req.json();
    const { data, error } = await ctx.supabaseAdmin.from('Test').update({ [key]: value }).eq('name', name).select();
    if (error) {
      return Response.json({ error: error.message }, { status: 500 });
    }
    return Response.json({ data, mySecret: Deno.env.get("MY_SECRET") });
  }),
};
