// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { corsHeaders } from "npm:@supabase/supabase-js@2/cors";

interface ReqPayload {
  name: string;
  key: string;
  value: string;
}

console.info("server started");

function jsonResponse(body: unknown, status = 200) {
  return Response.json(body, { status, headers: corsHeaders });
}

function getPublishableKey() {
  const publishableKeys = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");

  if (publishableKeys) {
    return JSON.parse(publishableKeys).default;
  }

  return Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ?? Deno.env.get("SUPABASE_ANON_KEY");
}

export default {
  fetch: async (req) => {
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const publishableKey = getPublishableKey();
    const authorization = req.headers.get("Authorization");

    if (!supabaseUrl || !publishableKey) {
      return jsonResponse({ error: "Missing Supabase function environment." }, 500);
    }

    if (!authorization?.startsWith("Bearer ")) {
      return jsonResponse({ error: "Missing user bearer token." }, 401);
    }

    const supabase = createClient(supabaseUrl, publishableKey, {
      global: {
        headers: {
          Authorization: authorization,
        },
      },
    });

    const { data: authData, error: authError } = await supabase.auth.getUser();

    if (authError || !authData.user) {
      return jsonResponse({ error: "Invalid user token." }, 401);
    }

    const { name, key, value }: ReqPayload = await req.json();
    const { data, error } = await supabase.from("Test").update({ [key]: value }).eq("name", name).select();

    if (error) {
      return jsonResponse({ error: error.message }, 500);
    }

    return jsonResponse({ data });
  },
};
