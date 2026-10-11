package org.lareferencia.backend.api.v5;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.contrib.dark.services.DarkCredentialService;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import java.util.List;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ApiV5DarkAuthenticationControllerTest {
    private MockMvc mvc;
    private DarkCredentialService credentials;
    private final UsernamePasswordAuthenticationToken admin = new UsernamePasswordAuthenticationToken("harvester-admin", "n/a",
            List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));
    private final DarkCredentialService.Status pending = new DarkCredentialService.Status("dark2", "pending_registration", "key-1",
            "fingerprint-1", "ssh-ed25519 public-only dark-minter", "raw-public-only", "authority-1", "https://minter.example.org",
            "/srv/dark/keys", null, "harvester-admin", null, null, null);

    @BeforeEach
    void setup() {
        credentials = mock(DarkCredentialService.class);
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5DarkAuthenticationController(credentials))
                .setMessageConverters(new org.springframework.http.converter.json.MappingJackson2HttpMessageConverter(),
                        new org.springframework.http.converter.StringHttpMessageConverter(java.nio.charset.StandardCharsets.UTF_8))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    @Test
    void returnsPublicManagementStateAndDownloadsOnlyCurrentPublicKey() throws Exception {
        when(credentials.status()).thenReturn(pending);
        mvc.perform(get("/api/v5/dark/authentication").principal(admin))
                .andExpect(status().isOk()).andExpect(jsonPath("$.registrationStatus").value("pending_registration"))
                .andExpect(jsonPath("$.privateKey").doesNotExist()).andExpect(jsonPath("$.publicKey").value(pending.publicKey()));
        mvc.perform(get("/api/v5/dark/authentication/credentials/key-1/public-key").principal(admin))
                .andExpect(status().isOk()).andExpect(content().string(pending.publicKey() + "\n"));
        mvc.perform(get("/api/v5/dark/authentication/credentials/old-key/public-key").principal(admin))
                .andExpect(status().isConflict());
    }

    @Test
    void forwardsConfirmationAndDisplayedIdentityWithoutImplyingRemoteVerification() throws Exception {
        when(credentials.resume("key-1", "fingerprint-1", "authority-1", "https://minter.example.org", true, "harvester-admin"))
                .thenReturn(pending);
        mvc.perform(post("/api/v5/dark/authentication/credentials/key-1/resume").principal(admin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"confirmed\":true,\"keyId\":\"fingerprint-1\",\"authorityId\":\"authority-1\",\"baseUrl\":\"https://minter.example.org\"}"))
                .andExpect(status().isOk());
        verify(credentials).resume("key-1", "fingerprint-1", "authority-1", "https://minter.example.org", true, "harvester-admin");
    }

    @Test
    void generationRequiresExplicitConfirmationAndReturnsUsefulConflict() throws Exception {
        when(credentials.generate(false, "key-1", "harvester-admin")).thenThrow(new IllegalArgumentException("Explicit confirmation is required"));
        mvc.perform(post("/api/v5/dark/authentication/credentials").principal(admin)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"confirmed\":false,\"expectedCredentialId\":\"key-1\"}"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("DARK_AUTHENTICATION_CONFLICT"));
    }
}
